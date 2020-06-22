import Foundation
import UIKit

struct CheckmarkFormViewModel: CellViewModel {
    typealias CellType = CheckmarkFormView

    let isEditable: Bool
    let title: String
    let isChecked: Bool
    let onClick: (() -> Void)?

    func setup(cell: CellType) {
        cell.checkmarkButton.isSelected = isChecked
        cell.checkmarkButton.setTitle(title, for: .normal)
        if isEditable {
            cell.onClick = onClick
        }
    }
}

class CheckmarkFormView: BaseXibView {
    @IBOutlet weak var checkmarkButton: UIButton!
    var onClick: (() -> Void)?

    @IBAction func didClickCheckmarkButton(_ sender: UIButton) {
        onClick?()
    }
}
