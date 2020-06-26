import UIKit



struct ProfileSubjectImageCollectionViewCellModel: CellViewModel {
    typealias CellType = ProfileSubjectImageCollectionViewCell

    let id: String
    let photo: URL?
    let fullName: String
    let birthDay: Date

    func setup(cell: CellType) {
        cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.width / 2
        cell.avatarImageView.clipsToBounds = true

        cell.subjectSelectView.layer.cornerRadius = cell.subjectSelectView.frame.width / 2
        cell.subjectSelectView.clipsToBounds = true
        if cell.isSelected {
            cell.subjectSelectView.backgroundColor = R.color.main()
        } else {
            cell.subjectSelectView.backgroundColor = .white
        }

        if let photoURL = photo {
            cell.avatarImageView.image = UIImage(contentsOfFile: photoURL.path)
        } else {
            cell.avatarImageView.image = R.image.avatar_default()
        }
    }
}

class ProfileSubjectImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var subjectSelectView: UIView!

    override var isSelected: Bool {
        didSet {
            if isSelected {
                subjectSelectView.backgroundColor = R.color.main()
            } else {
                subjectSelectView.backgroundColor = .white
            }
        }
    }
}
