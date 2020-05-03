import Foundation
import UIKit

struct StoriesTableViewCellModel: CellViewModel {
    typealias CellType = StoriesTableViewCell

    var title: String?
    let date: Date
    var details: String?
    var photo: UIImage?
    var photoCaption: String?

    var isSelected = false

    func setup(cell: CellType) {
        cell.backgroundColor = isSelected ? R.color.background() : .white

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        cell.dateLabel.text = formatter.string(from: date)
        cell.titleLabel.text = title
        cell.photoImageView.image = photo
    }
}

class StoriesTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}
