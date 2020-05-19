import UIKit



class SubjectListTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}


struct SubjectListTableViewCellModel: CellViewModel {

    typealias CellType = SubjectListTableViewCell

    let id: String?
    let title: String
    let photo: URL?


    func setup(cell: CellType) {
        cell.photoImageView.layer.cornerRadius = cell.photoImageView.frame.width / 2
        cell.photoImageView.clipsToBounds = true

        if let photoURL = photo {
            cell.photoImageView.image = UIImage(contentsOfFile: photoURL.path)
        } else {
            cell.photoImageView.image = UIImage(named: "avatar_default")
        }

        if id == nil {
            cell.photoImageView.isHidden = true
            cell.titleLabel.text = nil
            cell.textLabel?.text = title
            cell.textLabel?.textAlignment = .center
        } else {
            cell.photoImageView.isHidden = false
            cell.titleLabel.text = title
            cell.textLabel?.text = nil
        }
    }
}
