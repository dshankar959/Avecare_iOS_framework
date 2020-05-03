import Foundation
import UIKit

struct HomeTableViewHeaderViewModel: CellViewModel {
    typealias CellType = HomeTableViewHeaderView

    let icon: UIImage?
    let text: String

    func setup(cell: CellType) {
        if let icon = icon {
            cell.iconImageView?.image = icon
        } else {
            cell.iconImageView?.removeFromSuperview()
        }
        cell.titleLabel.text = text
    }
}

class HomeTableViewHeaderView: BaseXibView {
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
}
