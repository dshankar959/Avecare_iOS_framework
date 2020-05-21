import UIKit



struct LogsViewModelFactory {

    static func viewModel(for row: RLMLogRow, storage: ImageStorageService) -> AnyCellViewModel {
        switch row.rowType {
        case .option: return viewModel(for: row.option!)
        case .time: return viewModel(for: row.time!)
        case .switcher: return viewModel(for: row.switcher!)
        case .note: return viewModel(for: row.note!)
        case .photo: return viewModel(for: row.photo!, storage: storage)
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

    static func viewModel(for row: RLMLogPhotoRow, storage: ImageStorageService) -> LogsPhotoTableViewCellModel {
        return .init(row: row, storage: storage)
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

    init(row: RLMLogPhotoRow, storage: ImageStorageService) {
        if let url = storage.imageURL(name: row.id) {
            image = UIImage(contentsOfFile: url.path)
        } else {
            image = nil
        }
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

        if let selectedText = row.options.first(where: { $0.value == row.selectedValue })?.text {
            selectedOption2 = selectedText
        }
    }

}
