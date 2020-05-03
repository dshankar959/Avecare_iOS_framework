import Foundation
import UIKit

struct StoriesDetailsPhotoViewModel: CellViewModel {
    typealias CellType = StoriesDetailsPhotoView

    let image: UIImage
    let description: String?

    func setup(cell: CellType) {
        cell.photoImageView.image = image
        cell.captionTextLabel.text = description
    }
}

class StoriesDetailsPhotoView: BaseXibView {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextLabel: UILabel!
}
