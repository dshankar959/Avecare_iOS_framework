import Foundation
import UIKit

struct StoriesDetailsTitleViewModel: CellViewModel {
    typealias CellType = StoriesDetailsTitleView

    let title: String
    let description: String
    let date: Date

    func setup(cell: CellType) {
        cell.titleLabel.text = title
        cell.descriptionTextLabel.text = description
        cell.dateLabel.text = Date.ymdFormatter2.string(from: date)
    }
}

class StoriesDetailsTitleView: BaseXibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextLabel: UILabel!
}
