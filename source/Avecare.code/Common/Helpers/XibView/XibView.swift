import Foundation
import UIKit



protocol XibView: class {
    func setupContentView()
}


extension XibView where Self: UIView {

    func setupContentView() {
        let metatype = type(of: self)
        let bundle = Bundle(for: metatype)
        let name = String(describing: metatype)
        guard let view = UINib(nibName: name, bundle: bundle).instantiate(withOwner: self).first as? UIView else {
            fatalError("XibView failed to initialize `\(name).xib`")
        }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

}


class BaseXibView: UIView, XibView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    func setup() {
        setupContentView()
    }
}
