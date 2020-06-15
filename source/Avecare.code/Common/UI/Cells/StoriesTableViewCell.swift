import Foundation
import UIKit
import Kingfisher



struct StoriesTableViewCellModel: CellViewModel {
    typealias CellType = StoriesTableViewCell

    var title: String?
    let date: Date
    var documentURL: URL?
    var isPublished: Bool = false
    var isSelected = false

    func setup(cell: CellType) {
        cell.backgroundColor = isSelected ? R.color.background() : .white
        cell.dateLabel.text = Date.fullMonthDayFormatter.string(from: date)
        cell.titleLabel.text = title
        let service = DocumentService()
        let size = 375 * UIScreen.main.scale
        cell.status.isHidden = true

        if !isPublished {
            cell.status.isHidden = false
            cell.status.text = NSLocalizedString("draft_status", comment: "")
        }

        if let url = documentURL,
            url.absoluteString.isFilePath,
            let image = service.getImageForPDF(of: CGSize(width: size, height: size), for: url, atPage: 0) {
            cell.photoImageView.image = image
        } else {
            cell.photoImageView.image = R.image.noPdfPlaceholder()
        }
    }

}


class StoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var status: UILabel!
}
