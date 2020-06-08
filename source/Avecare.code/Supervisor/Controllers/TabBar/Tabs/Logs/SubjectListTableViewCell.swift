import UIKit
import Kingfisher



class SubjectListTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var subjectNameLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        photoImageView.layer.cornerRadius = 8
        photoImageView.layer.masksToBounds = true
    }

}


struct SubjectListTableViewCellModel: CellViewModel {
    typealias CellType = SubjectListTableViewCell

    let profilePhoto: URL?
    let firstName: String
    let lastName: String
    let birthDate: Date
    let isChecked: Bool


    init(subject: RLMSubject, storage: StorageService) {
        firstName = subject.firstName
        lastName = subject.lastName
        profilePhoto = subject.photoURL(using: storage)
        birthDate = subject.birthday
        isChecked = subject.isFormSubmittedToday
    }

    var isSelected: Bool = false

    func setup(cell: CellType) {
        cell.backgroundColor = isSelected ? R.color.background() : .white
        cell.subjectNameLabel.text = "\(lastName), \(firstName)"

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        cell.birthDateLabel.text = formatter.string(from: birthDate)

        cell.accessoryType = isChecked ? .checkmark : .none

        if let photoFileURL = profilePhoto {
            cell.photoImageView.kf.setImage(with: photoFileURL)
        } else {
            cell.photoImageView.image = R.image.avatar_default()
        }
    }

}
