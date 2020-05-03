import Foundation
import UIKit

@IBDesignable class DetailsNavigationView: BaseXibView {

    struct Options {
        var action: ((_ view: DetailsNavigationView, _ options: Options, _ index: Int) -> Void)?
        var isEnabled = true
        var text: String?
        var font: UIFont = .systemFont(ofSize: 14, weight: .bold)
        var textColor = R.color.darkText()
        var tintColor = R.color.main()
        var cornerRadius: CGFloat = 0
        var image: UIImage?
    }

    enum Item {
        case button(options: Options)
        case imageButton(options: Options)
        case offset(value: CGFloat)
    }

    @IBOutlet weak var stackView: UIStackView!

    var items = [Item]() {
        didSet {
            updateButtons()
        }
    }

    func updateButtons() {
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        for index in 0..<items.count {
            let item = items[index]
            switch item {
            case .button(let options):
                let button = UIButton(type: .system)
                button.setTitle(options.text, for: .normal)
                button.setTitleColor(options.textColor, for: .normal)
                button.backgroundColor = options.tintColor
                button.layer.cornerRadius = options.cornerRadius

                button.snp.makeConstraints { maker in
                    maker.width.equalTo(100)
                    maker.height.equalTo(40)
                }

                button.isEnabled = options.isEnabled
                if let action = options.action {
                    button.addAction { [unowned self] in
                        action(self, options, index)
                    }
                }

                stackView.addArrangedSubview(button)
            case .imageButton(let options):
                let button = UIButton(type: .system)
                button.tintColor = options.tintColor
                button.setImage(options.image, for: .normal)

                button.snp.makeConstraints { maker in
                    maker.width.height.equalTo(40)
                }

                button.isEnabled = options.isEnabled
                if let action = options.action {
                    button.addAction { [unowned self] in
                        action(self, options, index)
                    }
                }

                stackView.addArrangedSubview(button)
            case .offset(let value):
                let offsetView = UIView()
                offsetView.snp.makeConstraints { maker in
                    maker.width.equalTo(value)
                }
                stackView.addArrangedSubview(offsetView)
            }
        }
    }

}
