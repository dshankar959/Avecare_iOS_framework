import Foundation
import UIKit
import Kingfisher

struct SubjectPickerTableViewCellModel: CellViewModel {
    typealias CellType = SubjectPickerTableViewCell

    let isSelected: Bool
    let profilePhotoURL: URL?
    let subjectName: String

    func setup(cell: CellType) {
        cell.checkboxImageView.image = isSelected ? R.image.checkmark_on() : R.image.checkmark_off()
        cell.photoImageView.kf.setImage(with: profilePhotoURL)
        cell.subjectLabel.text = subjectName
    }
}

class SubjectPickerTableViewCell: UITableViewCell {
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var subjectLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        // #ui automated testing support
        checkboxImageView.accessibilityIdentifier = "ui_supervisor_subjectpicker_checkbox"

        photoImageView.layer.cornerRadius = 12
        photoImageView.layer.masksToBounds = true
    }
}
