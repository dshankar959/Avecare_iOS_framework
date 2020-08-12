import UIKit



struct AboutTableViewCellModel: CellViewModel {
    typealias CellType = AboutTableViewCell

    var menuTitle: String

    func setup(cell: AboutTableViewCell) {
        cell.menuTitleLabel.text = menuTitle
    }

}


class AboutTableViewCell: UITableViewCell {

    @IBOutlet weak var menuTitleLabel: UILabel!
    @IBOutlet weak var accessoryViewLabel: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
