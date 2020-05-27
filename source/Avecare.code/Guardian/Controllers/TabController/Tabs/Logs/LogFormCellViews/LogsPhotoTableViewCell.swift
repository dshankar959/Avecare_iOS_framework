import Foundation
import UIKit

struct LogsPhotoTableViewCellModel: CellViewModel {
    typealias CellType = LogsPhotoTableViewCell

    let image: UIImage?
    let caption: String?

    func setup(cell: CellType) {
        cell.detailsPhotoView.photoImageView.image = image
        cell.detailsPhotoView.captionTextLabel.text = caption
    }
}

class LogsPhotoTableViewCell: UITableViewCell {
    @IBOutlet weak var detailsPhotoView: StoriesDetailsPhotoView!
}
