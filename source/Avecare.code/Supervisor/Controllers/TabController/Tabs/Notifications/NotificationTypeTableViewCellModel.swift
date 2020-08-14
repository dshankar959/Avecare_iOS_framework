import Foundation
import UIKit

enum NotificationType {
    case dailyCheckList
    case classActivity
    case injuryReport
    case reminders
}

struct NotificationTypeTableViewCellModel: CellViewModel {
    typealias CellType = DefaultTableViewCell

    let icon: UIImage?
    let color: UIColor?
    let title: String
    let type: NotificationType

    var isSelected: Bool = false

    func setup(cell: CellType) {
        cell.backgroundColor = isSelected ? R.color.background() : .white

        cell.mainContentView.iconColor = color
        cell.mainContentView.iconImage = icon
        cell.mainContentView.nameText = title
    }
}
