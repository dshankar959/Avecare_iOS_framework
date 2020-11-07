import Foundation
import UIKit

class TimeRangePickerView: BaseXibView {
    @IBOutlet weak var pickerTitlesView: UIStackView!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!


    override init(frame: CGRect) {
        super.init(frame: frame)

        if #available(iOS 13.4, *) {
            startTimePicker.preferredDatePickerStyle = .wheels
            endTimePicker.preferredDatePickerStyle = .wheels
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var isDoublePicker: Bool = true {
        didSet {
            pickerTitlesView.isHidden = !isDoublePicker
            endTimePicker.isHidden = !isDoublePicker
        }
    }

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
