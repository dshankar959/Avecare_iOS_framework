import UIKit


class SubjectListTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}

struct SubjectListTableViewCellModel: CellViewModel {

    typealias CellType = SubjectListTableViewCell

    let title: String
    let photo: URL?

    func setup(cell: CellType) {
        cell.titleLabel.text = title

        cell.photoImageView.layer.cornerRadius = cell.photoImageView.frame.width / 2
        cell.photoImageView.clipsToBounds = true
        if let photoURL = photo {
            cell.photoImageView.image = UIImage(contentsOfFile: photoURL.path) ?? R.image.avatar_default()
        } else {
            cell.photoImageView.image = R.image.avatar_default()
        }
    }
}


struct SubjectListAllTableViewCell: CellViewModel {
    typealias CellType = UITableViewCell

    func setup(cell: CellType) {
        cell.textLabel?.text = "All"
        cell.textLabel?.textAlignment = .center
    }
}
