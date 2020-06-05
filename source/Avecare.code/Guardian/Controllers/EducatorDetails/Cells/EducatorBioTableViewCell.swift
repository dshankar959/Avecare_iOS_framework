import UIKit



struct EducatorBioTableViewCellModel: CellViewModel {
    typealias CellType = EducatorBioTableViewCell

    let title: String
    let lastname: String
    let bio: String

    func setup(cell: EducatorBioTableViewCell) {
        if title.count > 0 {
            cell.nameLabel.text = title + " " + lastname
        } else {
            cell.nameLabel.text = "Ms. " + lastname
        }

        cell.bioLabel.text = bio
    }
}

class EducatorBioTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var educationHeaderLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        educationHeaderLabel.text = NSLocalizedString("educator_training_header", comment: "").uppercased()
    }

}
