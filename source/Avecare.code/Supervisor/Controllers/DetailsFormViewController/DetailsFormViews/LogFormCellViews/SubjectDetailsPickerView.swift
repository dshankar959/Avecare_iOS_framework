import Foundation
import UIKit

struct SubjectDetailsPickerViewModel: CellViewModel {
    typealias CellType = SubjectDetailsPickerView

    let icon: UIImage?
    let iconColor: UIColor?
    let title: String
    var selectedOption: String
    var action: ((CellType) -> Void)? = nil
    var onRemoveCell: (() -> Void)? = nil
    let isEditable: Bool

    func setup(cell: CellType) {
        cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        cell.iconImageView.tintColor = iconColor
        cell.iconImageView.image = icon
        cell.titleLabel.text = title
        cell.selectedOptionButton.setTitle(selectedOption, for: .normal)

        if isEditable {
            cell.swipeToDeleteEnabled = true
            cell.onClick = action
            cell.onRemoveCell = onRemoveCell
        }
    }
}


class SubjectDetailsPickerView: LogFormCellView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedOptionButton: UIButton!

    var onClick: ((SubjectDetailsPickerView) -> Void)?

    override func setup() {
        super.setup()

        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 12
    }

    @IBAction func didClickOptionButton(_ sender: UIButton) {
        onClick?(self)
    }
}
