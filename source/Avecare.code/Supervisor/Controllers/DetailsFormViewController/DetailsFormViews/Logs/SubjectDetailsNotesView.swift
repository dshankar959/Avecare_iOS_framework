import Foundation
import UIKit

struct SubjectDetailsNotesViewModel: CellViewModel {
    typealias CellType = SubjectDetailsNotesView

    let icon: UIImage?
    let iconColor: UIColor?

    let title: String
    let placeholder: String
    var note: String?

    var didEndEditing: ((CellType) -> Void)? = nil

    func setup(cell: CellType) {
        cell.iconImageView.backgroundColor = iconColor?.withAlphaComponent(0.3)
        cell.iconImageView.tintColor = iconColor
        cell.iconImageView.image = icon
        cell.titleLabel.text = title

        cell.textView.text = note

        cell.onEndEditing = didEndEditing

        cell.updatePlaceholderVisibility()
    }
}

class SubjectDetailsNotesView: BaseXibView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewPlaceholder: UILabel!

    var characterLimit = 140

    var onEndEditing: ((SubjectDetailsNotesView) -> Void)?

    override func setup() {
        super.setup()

        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = 12

        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        textContainerView.layer.borderWidth = 0.5
        textContainerView.layer.cornerRadius = 4
        textContainerView.layer.masksToBounds = true
        textContainerView.layer.borderColor = R.color.lightText()?.cgColor
    }

    func updatePlaceholderVisibility() {
        textViewPlaceholder.isHidden = textView.text.count > 0
    }
}

extension SubjectDetailsNotesView: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        textViewPlaceholder.isHidden = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
        onEndEditing?(self)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentLength = textView.text.count
        let addition = text.count - range.length

        return (currentLength + addition) <= characterLimit
    }
}