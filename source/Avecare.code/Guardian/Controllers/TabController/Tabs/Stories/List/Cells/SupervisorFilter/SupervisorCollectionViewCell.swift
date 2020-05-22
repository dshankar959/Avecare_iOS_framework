import UIKit



struct SupervisorCollectionViewCellModel: CellViewModel {
    typealias CellType = SupervisorCollectionViewCell

    let id: String
    let title: String
    let name: String
    let photo: URL?

    func setup(cell: CellType) {
        cell.photoImageView.layer.cornerRadius = cell.photoImageView.frame.height / 2
        cell.photoImageView.clipsToBounds = true

        if let photoURL = photo {
            cell.photoImageView.image = UIImage(contentsOfFile: photoURL.path)
        } else {
            cell.photoImageView.image = R.image.avatar_default()
        }

        cell.titleLabel.text = title
        cell.nameLabel.text = name
    }
}


class SupervisorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
}
