import Foundation
import UIKit

struct LogsOptionTableViewCellModel: CellViewModel {
    typealias CellType = LogsOptionTableViewCell

    let icon: UIImage?
    let iconColor: UIColor?
    let title: String
    var selectedOption: String?

    func setup(cell: CellType) {
        cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        cell.iconImageView.tintColor = iconColor
        cell.iconImageView.image = icon
        cell.titleLabel.text = title
        cell.optionLabel.text = selectedOption
    }
}

class LogsOptionTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 12
    }
}
