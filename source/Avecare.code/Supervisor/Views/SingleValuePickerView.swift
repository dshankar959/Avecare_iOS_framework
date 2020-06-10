import Foundation
import UIKit



protocol SingleValuePickerItem {
    var pickerTextValue: String { get }
}


extension SingleValuePickerItem where Self: CustomStringConvertible {
    var pickerTextValue: String {
        return description
    }
}


class SingleValuePickerView<T: SingleValuePickerItem>: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    let values: [T]

    var selectedValue: T? {
        get {
            guard values.count > 0 else {
                return nil
            }
            return values[selectedRow(inComponent: 0)]
        }
        set {
            guard let value = newValue,
                  let index = values.firstIndex(where: { $0.pickerTextValue == value.pickerTextValue }) else {
                return
            }
            selectRow(index, inComponent: 0, animated: false)
        }
    }

    init(values: [T]) {
        self.values = values
        super.init(frame: .zero)

        delegate = self
        dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return values[row].pickerTextValue
    }

}
