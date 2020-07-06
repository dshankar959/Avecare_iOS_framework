import Foundation
import UIKit

struct HomeTableViewDisclosureCellModel: CellViewModel {
    typealias CellType = HomeTableViewDisclosureCell

    let feed: GuardianFeed
    let title: String
    let subjectImageURL: URL?

    func setup(cell: CellType) {
        cell.iconImageView.layer.cornerRadius = cell.iconImageView.frame.width / 4
        cell.iconImageView.clipsToBounds = true
        if feed.feedItemType == .subjectDailyLog,
            let photoURL = subjectImageURL,
            let image = UIImage(contentsOfFile: photoURL.path) {
            cell.iconImageView.image = image
            cell.iconImageView.contentMode = .scaleAspectFit
            cell.subtitleLabel.text = feed.date.dateStringWithDayOfWeekHumanFriendly
        } else {
            let icon: UIImage?, iconColor: UIColor?
            switch feed.feedItemType {
            case .message:
                icon = R.image.hwccccLogoIcon()
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
            cell.subtitleLabel.text = feed.body
        }
        cell.titleLabel.text = title
        cell.selectionStyle = .default
        cell.titleLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cell.accessoryType = .none
    }
}

class HomeTableViewDisclosureCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
}
