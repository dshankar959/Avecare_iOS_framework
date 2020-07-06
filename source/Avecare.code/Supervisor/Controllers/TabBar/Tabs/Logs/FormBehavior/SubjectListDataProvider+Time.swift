import UIKit



extension SubjectDetailsPickerViewModel {

    init(row: RLMLogTimeRow, isEditable: Bool) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title
        let formatter = Date.timeFormatter
        selectedOption = formatter.string(from: row.startTime)
        if let endTime = row.endTime {
            selectedOption += " - " + formatter.string(from: endTime)
        }
        self.isEditable = isEditable
    }

}


extension SubjectListDataProvider {

    func viewModel(for row: RLMLogTimeRow,
                   editable: Bool,
                   at indexPath: IndexPath,
                   for rowIndex: Int,
                   updateCallback: @escaping (Date) -> Void) -> SubjectDetailsPickerViewModel {

        var viewModel = SubjectDetailsPickerViewModel(row: row, isEditable: editable)

        viewModel.action = { [weak self] view in
            self?.showTimePicker(from: view, row: row, at: indexPath, for: rowIndex, updateCallback: updateCallback)
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


    private func showTimePicker(from view: SubjectDetailsPickerView,
                                row: RLMLogTimeRow,
                                at indexPath: IndexPath,
                                for rowIndex: Int,
                                updateCallback: @escaping (Date) -> Void) {
        guard let responder = delegate?.customResponder else { return }

        let picker = TimeRangePickerView(frame: CGRect(x: 0, y: 0, width: 320, height: 278))
        picker.startTimePicker.date = row.startTime
        if let endTime = row.endTime {
            picker.endTimePicker.date = endTime
        } else {
            picker.isDoublePicker = false
        }
        picker.updateMinMaxRange()

        let toolbar = defaultToolbarView(onDone: { [weak self] in
            RLMLogTimeRow.writeTransaction {
                row.startTime = picker.startTimePicker.date
                if picker.isDoublePicker {
                    row.endTime = picker.endTimePicker.date
                }
            }
            updateCallback(Date())
            self?.viewModel(for: row, editable: true, at: indexPath, for: rowIndex, updateCallback: updateCallback).setup(cell: view)
            responder.resignFirstResponder()
        }, onCancel: {
            responder.resignFirstResponder()
        })
        responder.resignFirstResponder()
        responder.becomeFirstResponder(inputView: picker, accessoryView: toolbar)
    }

}
