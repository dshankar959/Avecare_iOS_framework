import Foundation
import UIKit

struct LogsTagsTableViewCellModel: CellViewModel {
    typealias CellType = LogsTagsTableViewCell

    let icon: UIImage?
    let iconColor: UIColor?
    let title: String
    var selectedOptions = [RLMOptionValue]()

    func setup(cell: CellType) {
        cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        cell.iconImageView.tintColor = iconColor
        cell.iconImageView.image = icon
        cell.titleLabel.text = title
        cell.selectedOptionsLabel.text = selectedOptions.map { $0.text }.joined(separator: ", ")
    }
}

class LogsTagsTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectedOptionsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 12
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
