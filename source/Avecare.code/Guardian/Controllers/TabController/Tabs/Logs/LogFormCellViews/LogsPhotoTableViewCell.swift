import Foundation
import UIKit

struct LogsPhotoTableViewCellModel: CellViewModel {
    typealias CellType = LogsPhotoTableViewCell

    let image: UIImage?
    let caption: String?

    func setup(cell: CellType) {
        if image == nil {
            cell.isHidden = true
        } else {
            cell.isHidden = false
            cell.detailsPhotoView.photoImageView.image = image
            cell.detailsPhotoView.captionTextLabel.text = caption
        }
    }
}

class LogsPhotoTableViewCell: UITableViewCell {
    @IBOutlet weak var detailsPhotoView: StoriesDetailsPhotoView!
}
