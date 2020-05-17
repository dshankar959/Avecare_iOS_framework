import Foundation
import UIKit
import Kingfisher

struct StoriesTableViewCellModel: CellViewModel {
    typealias CellType = StoriesTableViewCell

    var title: String?
    let date: Date
    var details: String?
    var photoURL: URL?
    var photoCaption: String?

    var isSelected = false

    func setup(cell: CellType) {
        cell.backgroundColor = isSelected ? R.color.background() : .white
        cell.dateLabel.text = Date.fullMonthDayFormatter.string(from: date)
        cell.titleLabel.text = title
        if let url = photoURL, url.absoluteString.isFilePath {
            cell.photoImageView.image = UIImage(contentsOfFile: url.path)
        } else {
            cell.photoImageView.kf.setImage(with: photoURL)
        }
    }
}

class StoriesTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}
