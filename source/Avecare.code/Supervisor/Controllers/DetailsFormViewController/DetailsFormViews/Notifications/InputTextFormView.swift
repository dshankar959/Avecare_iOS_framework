import UIKit



struct InputTextFormViewModel: CellViewModel {
    typealias CellType = InputTextFormView

    let title: String
    let placeholder: String
    var value: String?

    var onChange: ((CellType, String?) -> Void)?

    func setup(cell: CellType) {
        cell.onChange = onChange
        cell.titleLabel.text = title
        cell.textViewPlaceholder.text = placeholder
        cell.textView.text = value
        cell.updatePlaceholderVisibility()
    }
}


class InputTextFormView: BaseXibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewPlaceholder: UILabel!

    var onChange: ((InputTextFormView, String?) -> Void)?

    var characterLimit = 140

    override func setup() {
        super.setup()

        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        textContainerView.layer.borderWidth = 0.5
        textContainerView.layer.cornerRadius = 4
        textContainerView.layer.masksToBounds = true
        textContainerView.layer.borderColor = R.color.darkText()?.withAlphaComponent(0.1).cgColor
    }

    func updatePlaceholderVisibility() {
        textViewPlaceholder.isHidden = textView.text.count > 0
    }
}


extension InputTextFormView: UITextViewDelegate {

    public func textViewDidBeginEditing(_ textView: UITextView) {
        textViewPlaceholder.isHidden = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }

    public func textViewDidChange(_ textView: UITextView) {
        onChange?(self, textView.text)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentLength = textView.text.count
        let addition = text.count - range.length

        return (currentLength + addition) <= characterLimit
    }

}
