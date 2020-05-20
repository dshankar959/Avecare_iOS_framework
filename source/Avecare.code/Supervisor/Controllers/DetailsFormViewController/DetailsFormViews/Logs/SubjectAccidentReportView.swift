import Foundation
import UIKit

struct SubjectAccidentReportViewModel: CellViewModel {
    typealias CellType = SubjectAccidentReportView

    let time: Date
    let icon: UIImage?
    let iconColor: UIColor?

    var action: PickerViewFormViewModel.Action? = nil

    let isEditable: Bool

    func setup(cell: CellType) {
        cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        cell.iconImageView.tintColor = iconColor
        cell.iconImageView.image = icon

        var viewModel = Self.pickerViewModel(from: time)
        if isEditable {
            viewModel.action = action
        }
        viewModel.setup(cell: cell.pickerView)
    }

    static func pickerViewModel(from date: Date) -> PickerViewFormViewModel {
        let formatter = Date.timeFormatter
        return PickerViewFormViewModel(title: "Select Time",
                placeholder: "12:00pm",
                accessory: .clock,
                textValue: formatter.string(from: date),
                action: nil)
    }
}

class SubjectAccidentReportView: BaseXibView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var pickerView: PickerViewFormView!

    var onClick: ((SubjectAccidentReportView) -> Void)?

    override func setup() {
        super.setup()
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 12
    }
}
