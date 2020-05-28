import Foundation
import UIKit

struct HomeTableViewDisclosureCellModel: CellViewModel {
    typealias CellType = HomeTableViewDisclosureCell

    let icon: UIImage?
    let iconColor: UIColor?
    let title: String
    let subtitle: String?
    let hasMoreDate: Bool

    init(icon: UIImage?,
         iconColor: UIColor? = nil,
         title: String,
         subtitle: String?,
         hasMoreDate: Bool = true) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.hasMoreDate = hasMoreDate
    }

    func setup(cell: CellType) {
        cell.iconImageView.layer.cornerRadius = cell.iconImageView.frame.width / 4
        cell.iconImageView.clipsToBounds = true
        cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        cell.iconImageView.image = icon
        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
        if hasMoreDate {
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        } else {
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }
    }
}

class HomeTableViewDisclosureCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

}
