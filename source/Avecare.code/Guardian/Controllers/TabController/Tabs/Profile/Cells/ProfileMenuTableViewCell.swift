import UIKit



struct ProfileMenuTableViewCellModel: CellViewModel {
    typealias CellType = ProfileMenuTableViewCell

    var menuImage: String?
    var menuTitle: String?
    var disclosable = true

    func setup(cell: CellType) {
        cell.menuImageLabel.text = menuImage
        cell.menuTitleLabel.text = menuTitle
        cell.chevronLabel.isHidden = !disclosable
    }
}

class ProfileMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var menuImageLabel: UILabel!
    @IBOutlet weak var menuTitleLabel: UILabel!
    @IBOutlet weak var chevronLabel: UILabel!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
