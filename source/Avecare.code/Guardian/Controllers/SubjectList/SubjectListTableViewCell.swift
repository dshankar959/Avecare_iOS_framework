import Foundation
import UIKit

struct SubjectListTableViewCellModel: CellViewModel {
    typealias CellType = SubjectListTableViewCell

    let title: String
    let photo: UIImage?

    func setup(cell: CellType) {
        cell.photoImageView.image = photo
        cell.titleLabel.text = title
    }
}

class SubjectListTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}
