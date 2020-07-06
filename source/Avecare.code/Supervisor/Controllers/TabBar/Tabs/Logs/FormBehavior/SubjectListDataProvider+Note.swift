import UIKit



extension SubjectDetailsNotesViewModel {

    init(row: RLMLogNoteRow, isEditable: Bool) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title
        placeholder = "140 characters maximum."
        note = row.value
        self.isEditable = isEditable
    }

}


extension SubjectListDataProvider {

    func viewModel(for row: RLMLogNoteRow,
                   editable: Bool,
                   at indexPath: IndexPath,
                   for rowIndex: Int,
                   updateCallback: @escaping (Date) -> Void) -> SubjectDetailsNotesViewModel {

        var viewModel = SubjectDetailsNotesViewModel(row: row, isEditable: editable)

        viewModel.onTextChange = { view in
            RLMLogNoteRow.writeTransaction {
                if view.textView.text.count > 0 {
                    row.value = view.textView.text
                } else {
                    row.value = nil
                }
            }

            updateCallback(Date())
        }

        viewModel.onRemoveCell = { [weak self] in
            if let subject = self?.selectedSubject {
                RLMLogForm.writeTransaction {
                    subject.todayForm.rows.remove(at: rowIndex)
                }
                self?.delegate?.didUpdateModel(at: indexPath)
            }
        }

        return viewModel
    }
}
