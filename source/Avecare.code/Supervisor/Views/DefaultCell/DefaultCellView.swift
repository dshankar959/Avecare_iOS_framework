import Foundation
import UIKit

@IBDesignable class DefaultCellView: BaseXibView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    @IBInspectable var iconColor: UIColor? {
        didSet {
            iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
            iconImageView.tintColor = iconColor
        }
    }

    @IBInspectable var iconImage: UIImage? {
        didSet {
            iconImageView.image = iconImage
        }
    }

    @IBInspectable var nameText: String? {
        didSet {
            nameLabel.text = nameText
        }
    }

    override func setup() {
        super.setup()

        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 12

        iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        iconImageView.tintColor = iconColor
        iconImageView.image = iconImage
        nameLabel.text = nameText
    }
}
