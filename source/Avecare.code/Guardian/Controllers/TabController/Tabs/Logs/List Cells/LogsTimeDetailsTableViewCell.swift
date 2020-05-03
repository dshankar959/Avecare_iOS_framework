import Foundation
import UIKit

struct LogsTimeDetailsTableViewCellModel: CellViewModel {
    typealias CellType = LogsTimeDetailsTableViewCell

    let icon: UIImage?
    let iconColor: UIColor?
    let title: String
    var selectedOption1: String?
    var selectedOption2: String?

    func setup(cell: CellType) {
        cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        cell.iconImageView.tintColor = iconColor
        cell.iconImageView.image = icon

        cell.titleLabel.text = title
        cell.timeLabel.text = selectedOption1
        cell.optionLabel.text = selectedOption2
    }
}

class LogsTimeDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var optionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 12
    }
}
