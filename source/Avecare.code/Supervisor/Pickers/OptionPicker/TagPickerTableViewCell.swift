import Foundation
import UIKit
import Kingfisher

struct TagPickerTableViewCellModel: CellViewModel {
    typealias CellType = TagPickerTableViewCell

    let isSelected: Bool
    let optionName: String

    func setup(cell: CellType) {
        cell.checkbosImageView.image = isSelected ? R.image.checkmark_on() : R.image.checkmark_off()
        cell.tagLabel.text = optionName
    }
}

class TagPickerTableViewCell: UITableViewCell {
    @IBOutlet weak var checkbosImageView: UIImageView!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        tagView.layer.cornerRadius = 4
        tagView.clipsToBounds = true
    }
}
