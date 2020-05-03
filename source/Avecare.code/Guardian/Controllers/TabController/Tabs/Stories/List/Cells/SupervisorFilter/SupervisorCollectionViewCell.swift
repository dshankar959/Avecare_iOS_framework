import Foundation
import UIKit

struct SupervisorCollectionViewCellModel: CellViewModel {
    typealias CellType = SupervisorCollectionViewCell

    let name: String
    let image: UIImage?

    func setup(cell: CellType) {
        cell.photoImageView.image = image
        cell.nameLabel.text = name
    }
}

class SupervisorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
}
