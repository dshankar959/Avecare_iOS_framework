import Foundation
import UIKit

struct SubjectListTableViewCellModel: CellViewModel {
    typealias CellType = SubjectListTableViewCell

    let title: String
    let photo: UIImage?

    func setup(cell: CellType) {
        if let photo = photo {
            cell.photoImageView.image = photo
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

class SubjectListTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}
