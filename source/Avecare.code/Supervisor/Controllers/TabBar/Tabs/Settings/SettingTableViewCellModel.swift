import Foundation
import UIKit



struct SettingTableViewCellModel: CellViewModel {
    typealias CellType = DefaultTableViewCell

    let icon: UIImage?
    let color: UIColor?
    let text: String
    let isEnabled: Bool

    let action: (() -> Void)?

    var isSelected: Bool = false

    func setup(cell: CellType) {
        cell.backgroundColor = isSelected ? R.color.background() : .white

        cell.mainContentView.iconColor = color
        cell.mainContentView.iconImage = icon
        cell.mainContentView.nameLabel.text = text
        cell.mainContentView.nameLabel.numberOfLines = 0
        if !isEnabled {
            cell.mainContentView.nameLabel.textColor = UIColor.gray
        }
    }
}
