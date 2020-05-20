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
        if let photoURL = photo {
            cell.photoImageView.image = UIImage(contentsOfFile: photoURL.path)
            cell.photoImageView.layer.cornerRadius = cell.photoImageView.frame.width / 2
            cell.photoImageView.clipsToBounds = true
            cell.titleLabel.text = title
        } else {
            cell.titleLabel.text = nil
            cell.textLabel?.text = title
            cell.textLabel?.textAlignment = .center
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