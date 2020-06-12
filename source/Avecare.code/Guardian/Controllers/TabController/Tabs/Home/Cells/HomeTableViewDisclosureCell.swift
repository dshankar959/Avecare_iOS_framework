import Foundation
import UIKit

struct HomeTableViewDisclosureCellModel: CellViewModel {
    typealias CellType = HomeTableViewDisclosureCell

    let title: String
    let subtitle: String?
    let feedItemId: String
    let feedItemType: FeedItemType
    let subjectImageURL: URL?

    func setup(cell: CellType) {
        cell.iconImageView.layer.cornerRadius = cell.iconImageView.frame.width / 4
        cell.iconImageView.clipsToBounds = true
        if feedItemType == .subjectDailyLog,
            let photoURL = subjectImageURL,
            let image = UIImage(contentsOfFile: photoURL.path) {
            cell.iconImageView.image = image
            cell.iconImageView.contentMode = .scaleAspectFit
        } else {
            let icon: UIImage?, iconColor: UIColor?
            switch feedItemType {
            case .message:
                icon = R.image.sampleLogoIcon()
                iconColor = R.color.separator()
            case .subjectDailyLog:
                icon = R.image.userIcon()
                iconColor = R.color.blueIcon()
            case .subjectInjury:
                icon = R.image.exclamationIcon()
                iconColor = R.color.redIcon()
            case .subjectReminder:
                icon = R.image.clockIcon()
                iconColor = R.color.blueIcon()
            case .unitActivity:
                icon = R.image.classActivityIcon()
                iconColor = R.color.blueIcon()
            case .unitStory:
                icon = R.image.tabBarStoriesIcon()
                iconColor = R.color.blueIcon()
            default:
                icon = nil
                iconColor = nil
            }

            cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
            cell.iconImageView.image = icon
            cell.iconImageView.tintColor = iconColor
            cell.iconImageView.contentMode = .center
        }
        cell.titleLabel.text = title
        cell.subtitleLabel.text = subtitle
        switch feedItemType {
        case .subjectDailyLog, .message, .unitStory:
            cell.selectionStyle = .default
            cell.titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        default:
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
