import Foundation
import UIKit

protocol HomeDataProvider: class {
    var numberOfSections: Int { get }
    func numberOfRows(section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel
    func headerViewModel(for section: Int) -> HomeTableViewHeaderViewModel?
    func canDismiss(at indexPath: IndexPath) -> Bool
}

class DefaultHomeDataProvider: HomeDataProvider {
    private struct Section {
        let header: HomeTableViewHeaderViewModel?
        let dismiss: Bool
        let records: [AnyCellViewModel]
    }

    private lazy var dataSource: [Section] = {
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
    }()

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
}
