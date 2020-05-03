import Foundation
import UIKit

struct SubjectPickerTableViewCellModel: CellViewModel {
    typealias CellType = SubjectPickerTableViewCell

    let isSelected: Bool
    let photo: UIImage
    let subjectName: String

    func setup(cell: CellType) {
        cell.checkboxImageView.image = isSelected ? R.image.checkmark_on() : R.image.checkmark_off()
        cell.photoImageView.image = photo
        cell.subjectLabel.text = subjectName
    }
}

class SubjectPickerTableViewCell: UITableViewCell {
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var subjectLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        photoImageView.layer.cornerRadius = 12
        photoImageView.layer.masksToBounds = true
    }
}
