import UIKit



extension SubjectAccidentReportViewModel {

    init(row: RLMLogInjuryRow, isEditable: Bool) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        time = row.time
        self.isEditable = isEditable
    }

}


extension SubjectListDataProvider {

    func viewModel(for row: RLMLogInjuryRow,
                   editable: Bool,
                   at indexPath: IndexPath,
                   updateCallback: @escaping (Date) -> Void) -> SubjectAccidentReportViewModel {

        var viewModel = SubjectAccidentReportViewModel(row: row, isEditable: editable)

        let picker = UIDatePicker()
        picker.backgroundColor = .white
        picker.datePickerMode = .time

        viewModel.action = .init(onClick: { view in
            picker.date = row.time
            view.becomeFirstResponder()
        }, inputView: picker, onInput: { view, _ in

            RLMLogInjuryRow.writeTransaction {
                row.time = picker.date
            }

            updateCallback(Date())
            var pickerViewModel = SubjectAccidentReportViewModel.pickerViewModel(from: picker.date)
            pickerViewModel.action = viewModel.action
            pickerViewModel.setup(cell: view)
        })

        return viewModel
    }
}
