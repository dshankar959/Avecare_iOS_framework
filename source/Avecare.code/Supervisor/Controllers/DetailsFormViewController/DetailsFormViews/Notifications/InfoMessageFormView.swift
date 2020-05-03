import Foundation
import UIKit

struct InfoMessageFormViewModel: CellViewModel {
    typealias CellType = InfoMessageFormView

    let title: String
    let message: String

    func setup(cell: CellType) {
        cell.titleLabel.text = title
        cell.descriptionLabel.text = message
    }
}

class InfoMessageFormView: BaseXibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}
