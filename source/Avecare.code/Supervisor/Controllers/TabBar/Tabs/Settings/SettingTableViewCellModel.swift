import Foundation
import UIKit

struct SettingTableViewCellModel: CellViewModel {
    typealias CellType = DefaultTableViewCell

    let icon: UIImage?
    let color: UIColor?
    let text: String
    let action: (() -> Void)?

    func setup(cell: CellType) {
        cell.mainContentView.iconColor = color
        cell.mainContentView.iconImage = icon
        cell.mainContentView.nameText = text
    }
}
