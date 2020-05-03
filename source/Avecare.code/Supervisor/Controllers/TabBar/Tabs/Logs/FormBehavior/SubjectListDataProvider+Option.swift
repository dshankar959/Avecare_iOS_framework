import Foundation
import UIKit

extension SubjectDetailsPickerViewModel {
    init(row: RLMLogOptionRow) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title
        if let selectedId = row.selectedValue.value,
           let selectedText = row.options.filter("value = %@", selectedId).first?.text {
            selectedOption = selectedText
        } else {
            selectedOption = row.placeholder
        }
    }
}

extension RLMOptionValue: SingleValuePickerItem {
    var pickerTextValue: String {
        return text
    }
}

extension DefaultSubjectListDataProvider {

    func viewModel(for row: RLMLogOptionRow, at indexPath: IndexPath) -> SubjectDetailsPickerViewModel {
        var model = SubjectDetailsPickerViewModel(row: row)
        model.action = { [weak self] view in
            self?.showOptionPicker(from: view, row: row, at: indexPath)
        }
        return model
    }

    private func showOptionPicker(from view: SubjectDetailsPickerView, row: RLMLogOptionRow, at indexPath: IndexPath) {
        guard let responder = delegate?.customResponder else { return }
        let values: [RLMOptionValue] = Array(row.options)
        let pickerView = SingleValuePickerView(values: values)
        pickerView.backgroundColor = .white
        let toolbar = defaultToolbarView(onDone: { [weak self] in
            if let value = pickerView.selectedValue?.value {
                row.writeTransaction {
                    row.selectedValue.value = value
                }
                self?.viewModel(for: row, at: indexPath).setup(cell: view)
            }
            responder.resignFirstResponder()
        }, onCancel: {
            responder.resignFirstResponder()
        })

        responder.becomeFirstResponder(inputView: pickerView, accessoryView: toolbar)
    }
}
