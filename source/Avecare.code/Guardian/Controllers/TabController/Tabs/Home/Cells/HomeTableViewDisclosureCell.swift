import Foundation
import UIKit

struct HomeTableViewDisclosureCellModel: CellViewModel {
    typealias CellType = HomeTableViewDisclosureCell

    let icon: UIImage?
    let title: String
    let subtitle: String?

    func setup(cell: CellType) {
        cell.iconImageView.image = icon
        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
    }
}

class HomeTableViewDisclosureCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

}
