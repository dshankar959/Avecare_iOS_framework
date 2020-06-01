import Foundation
import UIKit

struct HomeTableViewDisclosureCellModel: CellViewModel {
    typealias CellType = HomeTableViewDisclosureCell

    let icon: UIImage?
    let iconColor: UIColor?
    let title: String
    let subtitle: String?
    let feedItemId: String
    let feedItemType: FeedItemType

    init(icon: UIImage?,
         iconColor: UIColor? = nil,
         title: String,
         subtitle: String?,
         feedItemId: String,
         feedItemType: FeedItemType) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.feedItemId = feedItemId
        self.feedItemType = feedItemType
    }

    func setup(cell: CellType) {
        cell.iconImageView.layer.cornerRadius = cell.iconImageView.frame.width / 4
        cell.iconImageView.clipsToBounds = true
        cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        cell.iconImageView.image = icon
        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
        if feedItemType == .subjectDailyLog {
            cell.selectionStyle = .default
            cell.titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            cell.selectionStyle = .none
            cell.titleLabel.textColor = #colorLiteral(red: 0.4941176471, green: 0.5215686275, blue: 0.6235294118, alpha: 1)
        }
        cell.accessoryType = .none
    }
}

class HomeTableViewDisclosureCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

}
