import Foundation
import UIKit

struct FormTextViewModel: CellViewModel {
    typealias CellType = FormTextView

    let font: UIFont
    let textColor: UIColor? = R.color.darkText()
    let placeholder: String
    let value: String?
    let isEditable: Bool

    var onChange: ((CellType, String?) -> Void)?

    func setup(cell: CellType) {
        if isEditable {
            cell.onChange = onChange
        } else {
            cell.layer.borderWidth = 0
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = true
            cell.layer.borderColor = UIColor.clear.cgColor

            let edges = cell.textView.textContainerInset
            cell.textView.backgroundColor = R.color.background()
            cell.textView.textContainerInset = UIEdgeInsets(top: edges.top, left: 0, bottom: edges.bottom, right: 0)
            cell.textView.textContainer.lineFragmentPadding = 0
        }

        cell.textView.font = font
        cell.textViewPlaceholder.font = font
        cell.textViewPlaceholder.text = placeholder
        cell.textView.text = value
        cell.textViewPlaceholder.adjustsFontSizeToFitWidth = true

        cell.updatePlaceholderVisibility()

        if let color = textColor {
            cell.textView.textColor = color
        }

        cell.textView.isUserInteractionEnabled = isEditable
    }
}

class FormTextView: BaseXibView {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewPlaceholder: UILabel!

    var onChange: ((FormTextView, String?) -> Void)?

    override func setup() {
        super.setup()

        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        backgroundColor = R.color.mainInversion()

        layer.borderWidth = 1
        layer.cornerRadius = 4
        layer.masksToBounds = true
        layer.borderColor = R.color.darkText()?.withAlphaComponent(0.1).cgColor
    }

    func updatePlaceholderVisibility() {
        textViewPlaceholder.isHidden = textView.text.count > 0
    }
}

extension FormTextView: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        textViewPlaceholder.isHidden = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }

    public func textViewDidChange(_ textView: UITextView) {
        onChange?(self, textView.text)
    }
}
