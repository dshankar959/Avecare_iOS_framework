import UIKit
import SnapKit



@IBDesignable class LeftSideNavigationBarView: BaseXibView {

    @IBOutlet weak var logoIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func setup() {
        super.setup()

        titleLabel.adjustsFontSizeToFitWidth = true
        logoIcon.contentMode = .scaleAspectFit

        logoIcon.snp.remakeConstraints { (make) -> Void in
            make.width.equalTo(100)
            make.height.equalTo(25)
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-10)
        }

        titleLabel.snp.remakeConstraints { [unowned self] (make) -> Void in
            make.height.equalTo(25)
            make.top.equalTo(self.logoIcon.snp.top)
            make.left.equalTo(logoIcon.snp.right).offset(20)
            make.right.equalToSuperview()
        }

        if let unitId = RLMSupervisor.details?.primaryUnitId {
            titleLabel.text = RLMUnit.details(for: unitId)?.name ?? "Room ???"
        }
    }


}
