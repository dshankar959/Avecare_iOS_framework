import Foundation
import UIKit

extension SubjectDetailsNotesViewModel {
    init(row: RLMLogNoteRow) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title
        placeholder = "140 characters maximum."
        note = row.value
    }
}

extension SubjectListDataProvider {
    func viewModel(for row: RLMLogNoteRow, at indexPath: IndexPath) -> SubjectDetailsNotesViewModel {
        var viewModel = SubjectDetailsNotesViewModel(row: row)
        viewModel.didEndEditing = { view in
            RLMLogNoteRow.writeTransaction {
                if view.textView.text.count > 0 {
                    row.value = view.textView.text
                } else {
                    row.value = nil
                }
            }
        }
        return viewModel
    }
}
