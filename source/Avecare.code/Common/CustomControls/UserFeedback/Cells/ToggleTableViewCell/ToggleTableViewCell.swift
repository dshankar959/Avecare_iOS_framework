import UIKit
import CocoaLumberjack
import SnapKit



protocol ToggleTableViewCellDelegate: class {
    func didToggleSwitch(on: Bool)
}


class ToggleTableViewCell: UITableViewCell {

    private let toggleSwitch = UISwitch()

    weak var delegate: ToggleTableViewCellDelegate?

    var on: Bool = false {
        didSet {
            self.toggleSwitch.isOn = on
        }
    }


    required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        self.contentView.setSubviewForAutoLayout(toggleSwitch)

        toggleSwitch.addAction { [unowned self] in
            if let delegate = self.delegate {
                delegate.didToggleSwitch(on: self.toggleSwitch.isOn)
            }
        }
    }


    required public init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported.")
    }


    open override func layoutSubviews() {
        super.layoutSubviews()

        toggleSwitch.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }


    static var reuseIdentifier: String {
//        DDLogDebug("\(String(describing: self))")
        return String(describing: self)
    }

}
