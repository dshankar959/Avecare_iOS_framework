import Foundation
import UIKit



struct SettingTableViewCellModel: CellViewModel {
    typealias CellType = DefaultTableViewCell

    let icon: UIImage?
    let color: UIColor?
    let text: String

    let action: (() -> Void)?

    var isSelected: Bool = false

    func setup(cell: CellType) {
        cell.backgroundColor = isSelected ? R.color.background() : .white

        cell.mainContentView.iconColor = color
        cell.mainContentView.iconImage = icon
        cell.mainContentView.nameText = text
    }
}
