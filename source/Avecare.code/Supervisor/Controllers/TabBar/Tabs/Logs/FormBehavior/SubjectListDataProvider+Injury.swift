import Foundation
import UIKit

extension SubjectAccidentReportViewModel {
    init(row: RLMLogInjuryRow) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        time = row.time
    }
}

extension SubjectListDataProvider {
    func viewModel(for row: RLMLogInjuryRow, at indexPath: IndexPath) -> SubjectAccidentReportViewModel {
        var viewModel = SubjectAccidentReportViewModel(row: row)

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
            var pickerViewModel = SubjectAccidentReportViewModel.pickerViewModel(from: picker.date)
            pickerViewModel.action = viewModel.action
            pickerViewModel.setup(cell: view)
        })

        return viewModel
    }
}
