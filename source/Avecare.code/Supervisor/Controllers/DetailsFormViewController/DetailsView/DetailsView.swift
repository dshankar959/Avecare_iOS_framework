import Foundation
import UIKit
import SnapKit

@IBDesignable class DetailsView: BaseXibView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    var customInputView: UIView?
    var customInputAccessoryView: UIView?

    override func setup() {
        super.setup()
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
}

extension DetailsView {
    func addSeparator() {
        let view = UIView()
        view.backgroundColor = contentView.backgroundColor
        view.snp.makeConstraints { $0.height.equalTo(1) }
        stackView.addArrangedSubview(view)
    }

    func addView<T: CellViewModel>(with model: T) -> T.CellType {
        let view = model.buildView()
        stackView.addArrangedSubview(view)
        // swiftlint:disable:next force_cast
        return view as! T.CellType
    }

    func setFormViews(_ models: [AnyCellViewModel]) {
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        for viewModel in models {
            let view = viewModel.buildView()
            stackView.addArrangedSubview(view)
            addSeparator()
        }
    }
}

extension DetailsView: CustomResponder {
    override var inputView: UIView? {
        customInputView
    }

    override var inputAccessoryView: UIView? {
        customInputAccessoryView
    }

    func becomeFirstResponder(inputView: UIView?, accessoryView: UIView?) {
        customInputView = inputView
        customInputAccessoryView = accessoryView
        becomeFirstResponder()
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func resignFirstResponder() -> Bool {
        guard super.resignFirstResponder() else { return false }
        customInputView = nil
        customInputAccessoryView = nil
        return true
    }
}
