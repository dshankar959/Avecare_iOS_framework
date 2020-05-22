import UIKit



struct EducatorSummaryTableViewCellModel: CellViewModel {
    typealias CellType = EducatorSummaryTableViewCell

    var name: String = ""
    // swiftlint:disable line_length
    var summary: String = "Vestibulum dapibus leo nunc, sit amet malesuada magna sollicitudin vitae. Maecenas in justo sed nisi vulputate suscipit nec vitae arcu. Mauris at pretium leo, ultrices tincidunt leo. Vivamus urna lectus, moles tie eu lacus ut, blandit iaculis dolor."
    // swiftlint:enable line_length

    func setup(cell: EducatorSummaryTableViewCell) {
        cell.nameText.text = name
        cell.summaryText.text = summary
    }
}

class EducatorSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var summaryText: UILabel!
    @IBOutlet weak var educationHeaderLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        educationHeaderLabel.text = "Degrees, Certifications, and Training".uppercased()
    }

}
