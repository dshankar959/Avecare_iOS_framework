import UIKit
import CocoaLumberjack
import SnapKit



protocol ButtonTableViewCellDelegate: class {
    func didPressButton()
}


class ButtonTableViewCell: UITableViewCell {

    private let button = UIButton()

    weak var delegate: ButtonTableViewCellDelegate?


    required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        button.setTitle("Send", for: .normal)
        button.setTitleColor(iOSblue, for: .normal)
        button.setTitleColor(.black, for: .selected)
        button.setTitleColor(.black, for: .highlighted)

        button.clipsToBounds = true
        button.layer.cornerRadius = 5

        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = iOSblue.cgColor

        self.contentView.setSubviewForAutoLayout(button)

        button.addAction { [unowned self] in
            if let delegate = self.delegate {
                delegate.didPressButton()
            }
        }
    }


    required public init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported.")
    }


    open override func layoutSubviews() {
        super.layoutSubviews()

        button.snp.remakeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
    }


    static var reuseIdentifier: String {
//        DDLogDebug("\(String(describing: self))")
        return String(describing: self)
    }

}
