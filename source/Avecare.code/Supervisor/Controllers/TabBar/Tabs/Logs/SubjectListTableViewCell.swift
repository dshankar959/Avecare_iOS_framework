import Foundation
import UIKit

struct SubjectListTableViewCellModel: CellViewModel {
    typealias CellType = SubjectListTableViewCell

    enum Sort: Int {
        case lastName = 0
        case firstName = 1
        case date = 2
    }

    let image: UIImage?
    let firstName: String
    let lastName: String
    let date: Date
    let isChecked: Bool

    var isSelected: Bool = false

    func setup(cell: CellType) {
        cell.backgroundColor = isSelected ? R.color.background() : .white
        cell.photoImageView.image = image
        cell.subjectNameLabel.text = "\(lastName), \(firstName)"
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        cell.birthDateLabel.text = formatter.string(from: date)
        cell.accessoryType = isChecked ? .checkmark : .none
    }
}

class SubjectListTableViewCell: UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var subjectNameLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
}
