import UIKit



struct LogsViewModelFactory {

    static func viewModel(for row: RLMLogRow) -> AnyCellViewModel {
        switch row.rowType {
        case .option: return viewModel(for: row.option!)
        case .time: return viewModel(for: row.time!)
        case .switcher: return viewModel(for: row.switcher!)
        case .note: return viewModel(for: row.note!)
        case .photo: return viewModel(for: row.photo!)
        case .injury: return viewModel(for: row.injury!)
        }
    }

    static func viewModel(for row: RLMLogOptionRow) -> LogsOptionTableViewCellModel {
        return .init(row: row)
    }

    static func viewModel(for row: RLMLogTimeRow) -> LogsOptionTableViewCellModel {
        return .init(row: row)
    }

    static func viewModel(for row: RLMLogSwitcherRow) -> LogsTimeDetailsTableViewCellModel {
        return .init(row: row)
    }

    static func viewModel(for row: RLMLogNoteRow) -> LogsNoteTableViewCellModel {
        return .init(row: row)
    }

    static func viewModel(for row: RLMLogPhotoRow) -> LogsPhotoTableViewCellModel {
        return .init(row: row)
    }

    static func viewModel(for row: RLMLogInjuryRow) -> LogsNoteTableViewCellModel {
        return .init(row: row)
    }

}


extension LogsOptionTableViewCellModel {

    init(row: RLMLogOptionRow) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title
        if let selectedId = row.selectedValue.value,
           let selectedText = row.options.first(where: { $0.value == selectedId })?.text {
            selectedOption = selectedText
        }
    }

    init(row: RLMLogTimeRow) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title

        let formatter = Date.timeFormatter
        selectedOption = formatter.string(from: row.startTime) + " - " + formatter.string(from: row.endTime)
    }

}


extension LogsPhotoTableViewCellModel {

    init(row: RLMLogPhotoRow) {
//        if let imgName = row.imageUrl, let img = UIImage(named: imgName) {
//            image = img
//        } else {
            image = nil
//        }
        caption = row.text
    }

}


extension LogsNoteTableViewCellModel {

    init(row: RLMLogInjuryRow) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = "Accident Report"
        text = "Please see your child's educator upon pick-up"
    }

    init(row: RLMLogNoteRow) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title
        text = row.value
    }

}


extension LogsTimeDetailsTableViewCellModel {

    init(row: RLMLogSwitcherRow) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title
        let formatter = Date.timeFormatter
        selectedOption1 = formatter.string(from: row.startTime) + " - " + formatter.string(from: row.endTime)

        let selectedId = row.selectedValue
        if let selectedText = row.options.first(where: { $0.value == selectedId })?.text {
            selectedOption2 = selectedText
        }
    }

}
