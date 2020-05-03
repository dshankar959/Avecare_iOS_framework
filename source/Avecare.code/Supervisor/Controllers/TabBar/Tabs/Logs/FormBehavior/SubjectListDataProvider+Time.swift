import Foundation
import UIKit

extension SubjectDetailsPickerViewModel {
    init(row: RLMLogTimeRow) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title
        let formatter = Date.timeFormatter
        selectedOption = formatter.string(from: row.startTime) + " - " + formatter.string(from: row.endTime)
    }
}

extension DefaultSubjectListDataProvider {
    func viewModel(for row: RLMLogTimeRow, at indexPath: IndexPath) -> SubjectDetailsPickerViewModel {
        var viewModel = SubjectDetailsPickerViewModel(row: row)
        viewModel.action = { [weak self] view in
            self?.showTimePicker(from: view, row: row, at: indexPath)
        }
        return viewModel
    }

    private func showTimePicker(from view: SubjectDetailsPickerView, row: RLMLogTimeRow, at indexPath: IndexPath) {
        guard let responder = delegate?.customResponder else { return }

        let picker = TimeRangePickerView(frame: CGRect(x: 0, y: 0, width: 320, height: 278))
        picker.startTimePicker.date = row.startTime
        picker.endTimePicker.date = row.endTime
        picker.updateMinMaxRange()

        let toolbar = defaultToolbarView(onDone: { [weak self] in
            row.writeTransaction {
                row.startTime = picker.startTimePicker.date
                row.endTime = picker.endTimePicker.date
            }
            self?.viewModel(for: row, at: indexPath).setup(cell: view)
            responder.resignFirstResponder()
        }, onCancel: {
            responder.resignFirstResponder()
        })
        responder.becomeFirstResponder(inputView: picker, accessoryView: toolbar)
    }
}
