import UIKit



extension SubjectDetailsPickerViewModel {

    init(row: RLMLogOptionRow, isEditable: Bool) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title
        if let selectedId = row.selectedValue.value,
            let selectedText = row.options.filter("value = %@", selectedId).first?.text {
            selectedOption = selectedText
        } else {
            selectedOption = row.placeholder
        }
        self.isEditable = isEditable
    }
}

extension RLMOptionValue: SingleValuePickerItem {
    var pickerTextValue: String {
        return text
    }
}

extension SubjectListDataProvider {

    func viewModel(for row: RLMLogOptionRow,
                   editable: Bool,
                   at indexPath: IndexPath,
                   for rowIndex: Int,
                   updateCallback: @escaping (Date) -> Void) -> SubjectDetailsPickerViewModel {

        var model = SubjectDetailsPickerViewModel(row: row, isEditable: editable)

        model.action = { [weak self] view in
            self?.showOptionPicker(from: view, row: row, at: indexPath, for: rowIndex, updateCallback: updateCallback)
        }

        model.onRemoveCell = { [weak self] in
            if let subject = self?.selectedSubject {
                RLMLogForm.writeTransaction {
                    subject.todayForm.rows.remove(at: rowIndex)
                }
                self?.delegate?.didUpdateModel(at: indexPath)
            }
        }

        return model
    }

    private func showOptionPicker(from view: SubjectDetailsPickerView,
                                  row: RLMLogOptionRow,
                                  at indexPath: IndexPath,
                                  for rowIndex: Int,
                                  updateCallback: @escaping (Date) -> Void) {

        guard let responder = delegate?.customResponder else { return }
        let values: [RLMOptionValue] = Array(row.options)
        let pickerView = SingleValuePickerView(values: values)
        pickerView.backgroundColor = .white

        let toolbar = defaultToolbarView(onDone: { [weak self] in
            if let value = pickerView.selectedValue?.value {
                RLMLogOptionRow.writeTransaction {
                    row.selectedValue.value = value
                }
                updateCallback(Date())
                self?.viewModel(for: row, editable: true, at: indexPath, for: rowIndex, updateCallback: updateCallback).setup(cell: view)
            }
            responder.resignFirstResponder()
            }, onCancel: {
                responder.resignFirstResponder()
        })
        responder.resignFirstResponder()
        responder.becomeFirstResponder(inputView: pickerView, accessoryView: toolbar)
    }
}