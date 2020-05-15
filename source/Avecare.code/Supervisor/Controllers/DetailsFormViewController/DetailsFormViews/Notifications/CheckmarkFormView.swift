import Foundation
import UIKit

struct CheckmarkFormViewModel: CellViewModel {
    typealias CellType = CheckmarkFormView

    let title: String
    let isChecked: Bool
    let onClick: (() -> Void)?

    func setup(cell: CellType) {
        cell.checkmarkButton.isSelected = isChecked
        cell.checkmarkButton.setTitle(title, for: .normal)
        cell.onClick = onClick
    }
}

class CheckmarkFormView: BaseXibView {
    @IBOutlet weak var checkmarkButton: UIButton!
    var onClick: (() -> Void)?

    @IBAction func didClickCheckmarkButton(_ sender: UIButton) {
        onClick?()
    }
}
