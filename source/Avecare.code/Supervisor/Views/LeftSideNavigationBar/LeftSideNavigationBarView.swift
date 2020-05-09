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

        if let unitId = RLMSupervisor.details?.primaryUnitId {
            titleLabel.text = RLMUnit.details(for: unitId)?.name ?? title
        }



    }
}
