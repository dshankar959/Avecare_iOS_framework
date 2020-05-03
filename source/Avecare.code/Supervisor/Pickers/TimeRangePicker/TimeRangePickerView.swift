import Foundation
import UIKit

class TimeRangePickerView: BaseXibView {
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!

    func updateMinMaxRange() {
        endTimePicker.minimumDate = startTimePicker.date
        startTimePicker.maximumDate = endTimePicker.date
    }

    @IBAction func pickerValueDidChange(_ picker: UIDatePicker) {
        switch picker {
        case startTimePicker:
            endTimePicker.minimumDate = startTimePicker.date
        case endTimePicker:
            startTimePicker.maximumDate = endTimePicker.date
        default: break
        }
    }
}
