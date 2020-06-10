import Foundation

protocol HomeDataProvider: class {
    var numberOfSections: Int { get }
    func numberOfRows(section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel
    func headerViewModel(for section: Int) -> HomeTableViewHeaderViewModel?
    func canDismiss(at indexPath: IndexPath) -> Bool
    func fetchFeeds(completion: @escaping (AppError?) -> Void)
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
    private var subjectDict = [String: RLMSubject]()
    private let storage = DocumentService()

    init() {
        let subjects = RLMSubject.findAll()
        subjects.forEach { subject in
            subjectDict[subject.id] = subject
        }
    }

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

    func fetchFeeds(completion: @escaping (AppError?) -> Void) {
        if let guardianId = appSession.userProfile.accountTypeId {
            GuardiansAPIService.getGuardianFeed(for: guardianId) { result in
                switch result {
                case .success(let feeds):
                    let feedsFilteredByDatesWindow = self.filterFeedsForDatesWindow(with: feeds)
                    self.fetchedFeed = feedsFilteredByDatesWindow
                    self.constructDataSource(with: feedsFilteredByDatesWindow)
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
            let refarctoredFeeds = removeDuplicatedFeeds(from: fetchedFeed)
            constructDataSource(with: refarctoredFeeds)
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
                if let subject = subjectDict[feed.subjectId] {
                    importantItems.append(HomeTableViewDisclosureCellModel(with: feed,
                                                                           subject: subject,
                                                                           storage: storage))
                }

            }
            self.dataSource.append(
                Section(
                    header: .init(icon: R.image.pinIcon(), text: NSLocalizedString("home_important_section_title", comment: "").uppercased()),
                    dismiss: true,
                    records: importantItems)
            )
        }
        sectionHeaders.forEach { sectionHeader in
            let elements = sections[sectionHeader]
            var sectionItems = [HomeTableViewDisclosureCellModel]()
            elements?.forEach({ feed in
                if let subject = subjectDict[feed.subjectId] {
                    sectionItems.append(HomeTableViewDisclosureCellModel(with: feed,
                                                                         subject: subject,
                                                                         storage: storage))
                }
            })
            self.dataSource.append(
                Section(header: .init(icon: nil, text: sectionHeader.uppercased()),
                        dismiss: false,
                        records: sectionItems)
            )
        }
    }

    private func removeDuplicatedFeeds(from feeds: [RLMGuardianFeed]) -> [RLMGuardianFeed] {
        var resultFeeds = [RLMGuardianFeed]()
        var feedItemIds: Set<String> = []
        for feed in feeds {
            if !feedItemIds.contains(feed.feedItemId) {
                feedItemIds.insert(feed.feedItemId)
                resultFeeds.append(feed)
            }
        }
        return resultFeeds
    }

    private func filterFeedsForDatesWindow(with feeds: [RLMGuardianFeed]) -> [RLMGuardianFeed] {
        var resultFeeds = [RLMGuardianFeed]()
        for feed in feeds {
            let date: Date
            if feed.serverLastUpdated == nil {
                date = feed.date
            } else {
                date = feed.serverLastUpdated!
            }
            if date > SubjectsAPIService.startDateOfLogsHistory.startOfDay {
                resultFeeds.append(feed)
            } else {
                break
            }
        }
        return resultFeeds
    }
}

extension HomeTableViewDisclosureCellModel {
    init(with feed: RLMGuardianFeed, subject: RLMSubject, storage: DocumentService) {
        if feed.feedItemType == .subjectDailyLog {
            title = subject.firstName + NSLocalizedString("home_feed_title_dailylog", comment: "")
            subtitle = nil
            subjectImageURL = subject.photoURL(using: storage)
        } else {
            title = feed.header
            subtitle = feed.body
            subjectImageURL = nil
        }
        feedItemId = feed.feedItemId
        feedItemType = feed.feedItemType
    }
}
