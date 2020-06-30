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
        cell.photoImageView.set(cornerRadius: 12.0)

        let service = DocumentService()
        let size = 375 * UIScreen.main.scale
        cell.status.isHidden = true

        if !isPublished {
            cell.status.isHidden = false
            cell.status.text = NSLocalizedString("draft_status", comment: "")
        }
        cell.photoImageView.image = nil

        DispatchQueue.global(qos: .background).async {
            var image: UIImage? = nil
            if let url = self.documentURL,
                url.absoluteString.isFilePath {
                image = service.getImageForPDF(of: CGSize(width: size, height: size), for: url, atPage: 0)
            }
            DispatchQueue.main.async {
                if let image = image {
                    cell.photoImageView.image = image
                } else {
                    cell.photoImageView.image = R.image.noPdfPlaceholder()
                }
            }
        }
    }
}

class StoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var status: UILabel!
}
