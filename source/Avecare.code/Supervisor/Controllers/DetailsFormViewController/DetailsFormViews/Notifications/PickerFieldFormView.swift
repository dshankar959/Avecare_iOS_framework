import Foundation
import UIKit
import SnapKit

struct DoublePickerViewFormViewModel: AnyCellViewModel {
    private(set) static var cellType = UIView.self

    var leftPicker: PickerViewFormViewModel?
    var rightPicker: PickerViewFormViewModel?

    func setup(cell: UIView) {

    }

    func buildView() -> UIView {
        let view = UIView()

        view.snp.makeConstraints { maker in
            maker.height.equalTo(80)
        }

        // horizontal empty space in middle
        let spacer = UIView()
        spacer.snp.makeConstraints { maker in
            maker.width.equalTo(26)
        }

        let leftView: UIView
        let rightView: UIView

        if let left = leftPicker {
            leftView = left.buildView()
        } else {
            //dummy
            leftView = UIView()
        }

        if let right = rightPicker {
            rightView = right.buildView()
        } else {
            //dummy
            rightView = UIView()
        }

        let stackView = UIStackView(arrangedSubviews: [leftView, spacer, rightView])
        stackView.axis = .horizontal
        view.addSubview(stackView)
        stackView.snp.makeConstraints { maker in
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
            maker.edges.equalToSuperview().inset(insets)
        }

        leftView.snp.makeConstraints { maker in
            maker.width.equalTo(rightView)
        }

        return view
    }
}

struct PickerViewFormViewModel: CellViewModel {
    typealias CellType = PickerViewFormView

    struct Action {
        let onClick: ((CellType) -> Void)?
        let inputView: UIView?
        let onInput: ((CellType, UIView?) -> Void)?
    }

    enum Accessory {
        case dropdown
        case plus
        case calendar
        case clock
        case none

        var image: UIImage? {
            switch self {
            case .dropdown: return R.image.formDropdownIcon()
            case .clock: return R.image.formClockIcon()
            case .plus: return R.image.formPlusIcon()
            case .calendar: return R.image.formCalendarIcon()
            default: return nil
            }
        }
    }

    let title: String
    let placeholder: String
    let accessory: Accessory
    var textValue: String?
    var action: Action?

    func setup(cell: CellType) {
        cell.didTapAction = action?.onClick
        cell.customInputView = action?.inputView
        cell.didClickDone = action?.onInput

        cell.titleLabel.text = title
        cell.placeholderString = placeholder
        cell.setTextValue(textValue)
        cell.fieldAccessoryImageView.image = accessory.image
    }
}

@IBDesignable class PickerViewFormView: BaseXibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fieldLabel: UILabel!
    @IBOutlet weak var fieldBackgroundView: UIView!
    @IBOutlet weak var fieldAccessoryImageView: UIImageView!

    fileprivate var customInputView: UIView?
    var placeholderString: String?

    override var inputView: UIView? {
        return customInputView
    }

    override var inputAccessoryView: UIView? {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelInput)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneInput))]
        return toolbar
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    var didTapAction: ((PickerViewFormView) -> Void)?
    var didClickDone: ((PickerViewFormView, UIView?) -> Void)?

    func setTextValue(_ value: String?) {
        if let value = value {
            fieldLabel.text = value
            fieldLabel.textColor = R.color.darkText()
        } else {
            fieldLabel.text = placeholderString
            fieldLabel.textColor = R.color.lightText()
        }
    }

    override func setup() {
        super.setup()

        fieldBackgroundView.layer.cornerRadius = 4
        fieldBackgroundView.layer.borderColor = R.color.darkText()?.withAlphaComponent(0.1).cgColor
        fieldBackgroundView.layer.borderWidth = 0.5
    }

    @IBAction func didTapField(_ gesture: UITapGestureRecognizer) {
        didTapAction?(self)
    }

    @objc func cancelInput() {
        resignFirstResponder()
    }

    @objc func doneInput() {
        didClickDone?(self, inputView)
        resignFirstResponder()
    }
}