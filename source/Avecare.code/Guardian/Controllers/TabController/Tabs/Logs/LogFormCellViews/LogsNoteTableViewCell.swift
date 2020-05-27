import Foundation
import UIKit

struct LogsNoteTableViewCellModel: CellViewModel {
    typealias CellType = LogsNoteTableViewCell

    let icon: UIImage?
    let iconColor: UIColor?
    let title: String
    let text: String?

    func setup(cell: CellType) {
        cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        cell.iconImageView.tintColor = iconColor
        cell.iconImageView.image = icon

        cell.titleLabel.text = title
        cell.detailsLabel.text = text
    }
}

class LogsNoteTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 12
    }
}
