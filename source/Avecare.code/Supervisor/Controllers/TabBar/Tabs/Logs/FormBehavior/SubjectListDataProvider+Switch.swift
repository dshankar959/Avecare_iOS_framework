import Foundation
import UIKit

extension SubjectDetailsSegmentViewModel {
    init(row: RLMLogSwitcherRow) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title
        let formatter = Date.timeFormatter
        selectedOption = formatter.string(from: row.startTime) + " - " + formatter.string(from: row.endTime)

        segmentDescription = row.subtitle
        segmentValues = row.options.map({ $0.text })

        if let selectedId = row.selectedValue.value,
           let selectedText = row.options.filter("value = %@", selectedId).first?.text,
           let index = segmentValues.firstIndex(of: selectedText) {
            selectedSegmentIndex = index
        }
    }
}

extension DefaultSubjectListDataProvider {
    func viewModel(for row: RLMLogSwitcherRow, at indexPath: IndexPath) -> SubjectDetailsSegmentViewModel {
        var viewModel = SubjectDetailsSegmentViewModel(row: row)
        viewModel.action = .init(onClick: { [weak self] view in
            self?.showTimePicker(from: view, row: row, at: indexPath)
        }, onSegmentChange: { view, index in
            row.writeTransaction {
                row.selectedValue.value = row.options[index].value
            }
        })
        return viewModel
    }

    private func showTimePicker(from view: SubjectDetailsSegmentView, row: RLMLogSwitcherRow, at indexPath: IndexPath) {
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
