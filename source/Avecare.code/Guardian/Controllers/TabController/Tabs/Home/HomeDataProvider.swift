import Foundation
import UIKit

protocol HomeDataProvider: class {
    var numberOfSections: Int { get }
    func numberOfRows(section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel
    func headerViewModel(for section: Int) -> HomeTableViewHeaderViewModel?
    func canDismiss(at indexPath: IndexPath) -> Bool
    func fetchFeed(completion: @escaping (AppError?) -> Void)
    func filterDataSource(with subjectId: String?)
}

class DefaultHomeDataProvider: HomeDataProvider {
    private struct Section {
        let header: HomeTableViewHeaderViewModel?
        let dismiss: Bool
        let records: [AnyCellViewModel]
    }

    private var fetchedFeed = [RLMGuardianFeed]()
    private var dataSource = [Section]()

    /*
        return []   // hide for now until we have integrated with API
        return [
            Section(header: .init(icon: R.image.pinIcon(), text: "IMPORTANT ITEMS"),
                    dismiss: true,
                    records: [
                        LogsNoteTableViewCellModel(icon: R.image.injuryIcon(), iconColor: R.color.blueIcon(),
                                title: "Injury Report", text: "Speak with educator at pickup"),
                        LogsNoteTableViewCellModel(icon: R.image.exclamationIcon(), iconColor: R.color.redIcon(),
                                title: "Accident Report", text: R.string.placeholders.report())
                    ]),
            Section(header: .init(icon: nil, text: "TODAY"),
                    dismiss: false,
                    records: [
                        HomeTableViewDisclosureCellModel(icon: R.image.subject1(), title: "Brendan’s daily log is complete!", subtitle: nil),
                        LogsNoteTableViewCellModel(icon: R.image.formCalendarIcon(), iconColor: R.color.blueIcon(),
                                title: "Brendan's Class Outing", text: "Walking to the woods in the morning if weather allows."),
                        HomeTableViewDisclosureCellModel(icon: R.image.sampleLogo2Icon(), title: "Message From the Board", subtitle: "Holiday - School Closed"),
                        LogsNoteTableViewCellModel(icon: R.image.flagIcon(), iconColor: R.color.blueIcon(),
                                title: "School Training", text: "Routine fire drill"),
                        HomeTableViewDisclosureCellModel(icon: R.image.sampleLogoIcon(), title: "Monthly Newsletter", subtitle: "Available now")
                    ]),
            Section(header: .init(icon: nil, text: "Yesterday".uppercased()),
                    dismiss: false,
                    records: [
                        HomeTableViewDisclosureCellModel(icon: R.image.subject1(), title: "Brendan’s daily log is complete!", subtitle: nil),
                        LogsNoteTableViewCellModel(icon: R.image.tabBarStoriesIcon(), iconColor: R.color.blueIcon(),
                                title: "Brendan's Class", text: "Construction Zone Creation"),
                        HomeTableViewDisclosureCellModel(icon: R.image.subject2(), title: "Elise’s daily log is complete!", subtitle: nil)
                    ]),
            Section(header: .init(icon: nil, text: "Last Week".uppercased()),
                    dismiss: false,
                    records: [
                        HomeTableViewDisclosureCellModel(icon: R.image.subject1(), title: "Brendan’s daily log is complete!", subtitle: nil),
                        HomeTableViewDisclosureCellModel(icon: R.image.subject2(), title: "Elise’s daily log is complete!", subtitle: nil)
                    ])
        ]
    }()*/

    var numberOfSections: Int {
        return dataSource.count
    }

    func numberOfRows(section: Int) -> Int {
        return dataSource[section].records.count
    }

    func model(for indexPath: IndexPath) -> AnyCellViewModel {
        return dataSource[indexPath.section].records[indexPath.row]
    }

    func headerViewModel(for section: Int) -> HomeTableViewHeaderViewModel? {
        return dataSource[section].header
    }

    func canDismiss(at indexPath: IndexPath) -> Bool {
        return dataSource[indexPath.section].dismiss
    }

    func fetchFeed(completion: @escaping (AppError?) -> Void) {
        if let guardianId = appSession.userProfile.accountTypeId {
            GuardiansAPIService.getGuardianFeed(for: guardianId) { result in
                switch result {
                case .success(let feeds):
                    self.fetchedFeed = feeds
                    self.constructDataSource(with: feeds)
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        }
    }

    func filterDataSource(with subjectId: String?) {
        if let subjectId = subjectId {
            let filteredFeed = fetchedFeed.filter { $0.subjectId == subjectId }
            constructDataSource(with: filteredFeed)
        } else {
            constructDataSource(with: fetchedFeed)
        }
    }

    private func constructDataSource(with feeds: [RLMGuardianFeed]) {
        self.dataSource.removeAll()
        var importantList = [RLMGuardianFeed]()
        var headerSet = Set<String>()
        var sectionHeaders = [String]()
        var sections = [String: [RLMGuardianFeed]]()
        feeds.forEach { feed in
            if feed.important {
                importantList.append(feed)
            } else {
                let sectionTitle: String
                if let feedDate = feed.serverLastUpdated {
                    sectionTitle = feedDate.timeAgo(dayAbove: true)
                } else {
                    sectionTitle = feed.date.timeAgo(dayAbove: true) // Just in case serverLastUpdated is null
                }

                if !headerSet.contains(sectionTitle) {
                    sectionHeaders.append(sectionTitle)
                    sections[sectionTitle]?.append(feed)
                }
                headerSet.insert(sectionTitle)
                sections[sectionTitle] = [feed]
            }
        }
        if importantList.count > 0 {
            var importantItems = [HomeTableViewDisclosureCellModel]()
            importantList.forEach { feed in
                importantItems.append(self.makeCellModel(with: feed))
            }
            self.dataSource.append(
                Section(
                    header: .init(icon: R.image.pinIcon(), text: "IMPORTANT ITEMS"),
                    dismiss: true,
                    records: importantItems)
            )
        }
        sectionHeaders.forEach { sectionHeader in
            let elements = sections[sectionHeader]
            var sectionItems = [HomeTableViewDisclosureCellModel]()
            elements?.forEach({ feed in
                sectionItems.append(self.makeCellModel(with: feed))
            })
            self.dataSource.append(
                Section(header: .init(icon: nil, text: sectionHeader.uppercased()),
                        dismiss: false,
                        records: sectionItems)
            )
        }
    }

    private func makeCellModel(with feed: RLMGuardianFeed) -> HomeTableViewDisclosureCellModel {
        let cellModel: HomeTableViewDisclosureCellModel
        if feed.feedItemType == "message" {
            cellModel = HomeTableViewDisclosureCellModel(icon: R.image.flagIcon(),
                                                         iconColor: R.color.blueIcon(),
                                                         title: feed.header,
                                                         subtitle: feed.body,
                                                         hasMoreData: true)
        } else if feed.feedItemType == "subjectdailylog" {
            cellModel = HomeTableViewDisclosureCellModel(icon: R.image.pencilIcon(),
                                                         iconColor: R.color.blueIcon(),
                                                         title: feed.header,
                                                         subtitle: feed.body,
                                                         hasMoreData: true)
        } else if feed.feedItemType == "subjectinjury" {
            cellModel = HomeTableViewDisclosureCellModel(icon: R.image.injuryIcon(),
                                                         iconColor: R.color.blueIcon(),
                                                         title: feed.header,
                                                         subtitle: feed.body,
                                                         hasMoreData: false)
        } else if feed.feedItemType == "subjectreminder" {
            cellModel = HomeTableViewDisclosureCellModel(icon: R.image.heartIcon(),
                                                         iconColor: R.color.blueIcon(),
                                                         title: feed.header,
                                                         subtitle: feed.body,
                                                         hasMoreData: false)
        } else if feed.feedItemType == "unitactivity" {
            cellModel = HomeTableViewDisclosureCellModel(icon: R.image.classActivityIcon(),
                                                         iconColor: R.color.blueIcon(),
                                                         title: feed.header,
                                                         subtitle: feed.body,
                                                         hasMoreData: false)
        } else {
            cellModel = HomeTableViewDisclosureCellModel(icon: nil, iconColor: nil, title: "", subtitle: nil, hasMoreData: false)
        }
        return cellModel
    }
}
