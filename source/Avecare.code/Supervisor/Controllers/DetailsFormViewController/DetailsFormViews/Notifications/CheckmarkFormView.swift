import Foundation
import UIKit

struct CheckmarkFormViewModel: CellViewModel {
    typealias CellType = CheckmarkFormView

    let id: String
    let title: String
    let isChecked: Bool
    let onClick: ((String) -> Void)?

    func setup(cell: CellType) {
        cell.index = id
        cell.checkmarkButton.isSelected = isChecked
        cell.checkmarkButton.setTitle(title, for: .normal)
        cell.onClick = onClick
    }
}

class CheckmarkFormView: BaseXibView {
    @IBOutlet weak var checkmarkButton: UIButton!
    var index = 0
    var onClick: ((Int) -> Void)?

    @IBAction func didClickCheckmarkButton(_ sender: UIButton) {
        onClick?(index)
    }
}
