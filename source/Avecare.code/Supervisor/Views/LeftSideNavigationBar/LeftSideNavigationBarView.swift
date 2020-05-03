import Foundation
import UIKit

@IBDesignable class LeftSideNavigationBarView: BaseXibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBInspectable var title: String? /*{
        didSet {
            titleLabel.text = title
        }
    }*/

    override func setup() {
        super.setup()
        titleLabel.text = appDelegate._session.unitDetails?.name ?? title
    }
}
