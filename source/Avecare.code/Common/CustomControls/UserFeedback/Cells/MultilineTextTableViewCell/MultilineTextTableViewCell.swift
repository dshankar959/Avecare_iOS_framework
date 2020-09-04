import UIKit


private let textViewMargins = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 8.0, right: 8.0)
private let textContainerInset = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
private let textStyle = MultilineTextTableViewCellContentTextStyle()


class MultilineTextTableViewCell: UITableViewCell {

    var useForGroupName: Bool = false

    var contentTextView: UITextView? {
        didSet {
            if let textView = contentTextView {
                self.configure(textView: textView)
            }
        }
    }

    var placeholderTextView: UITextView? {
        didSet {
            if let textView = placeholderTextView {
                self.configure(textView: textView)
            }

            self.updatePlaceholderVisibility()
        }
    }

    weak var delegate: MultilineTextTableViewCellDelegate?

    var isEditable: Bool {
        get {
            return self.contentTextView?.isEditable ?? false
        }
        set {
            self.contentTextView?.isEditable = newValue
        }
    }

    var content: String? {
        get {
            return self.contentTextView?.attributedText.string
        }
        set {
            self.contentTextView?.attributedText = MultilineTextTableViewCell.attributedText(for: newValue ?? "")
            self.updatePlaceholderVisibility()
        }
    }

    var placeholder: String? {
        get {
            return self.placeholderTextView?.attributedText.string
        }
        set {
            self.placeholderTextView?.attributedText = MultilineTextTableViewCell.attributedText(for: newValue ?? "")
            self.updatePlaceholderVisibility()
        }
    }

    var placeholderIsHidden: Bool {
        if let content = self.content {
            return content.count > 0
        }

        return false
    }


    // MARK: -

    required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        placeholderTextView = UITextView()
        contentTextView = UITextView()

        placeholderTextView?.isEditable = false
        placeholderTextView?.isSelectable = false
        placeholderTextView?.backgroundColor = .white

        contentTextView?.backgroundColor = .clear
        contentTextView?.delegate = self
        contentTextView?.font = textStyle.font

        self.contentView.setSubviewForAutoLayout(placeholderTextView!)
        self.contentView.setSubviewForAutoLayout(contentTextView!)
    }


    required public init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported.")
    }


    open override func layoutSubviews() {
        super.layoutSubviews()

        placeholderTextView?.snp.remakeConstraints { (make) in
            make.left.top.equalToSuperview().offset(16)
            make.right.bottom.equalToSuperview().offset(-16)
        }

        contentTextView?.snp.remakeConstraints { (make) in
            make.left.top.equalToSuperview().offset(16)
            make.right.bottom.equalToSuperview().offset(-16)
        }
    }


    static var reuseIdentifier: String {
//        DDLogDebug("\(String(describing: self))")
        return String(describing: self)
    }


    // MARK: -

    static func attributedText(for text: String) -> NSAttributedString {
        var attributes = textStyle.attributes
        attributes[.foregroundColor] = UIColor.black.withAlphaComponent(0.54)

        return NSAttributedString(string: text, attributes: attributes)
    }

    static func rowHeight(for text: String, targetWidth: CGFloat) -> CGFloat {
        let attributedText = self.attributedText(for: text)

        let horizontalMargins = textViewMargins.left + textViewMargins.right
        let verticalMargins = textViewMargins.top + textViewMargins.bottom

        let horizontalPadding = textContainerInset.left + textContainerInset.right
        let verticalPadding = textContainerInset.top + textContainerInset.bottom

        let horizontalOffset = horizontalMargins + horizontalPadding
        let verticalOffset = verticalMargins + verticalPadding

        let targetSize = CGSize(width: targetWidth - horizontalOffset,
                                height: CGFloat.greatestFiniteMagnitude)

        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        let bounds = attributedText.boundingRect(with: targetSize, options: options, context: nil)
        let height = bounds.size.height + verticalOffset

        return height
    }

    private func configure(textView: UITextView) {
        textView.textContainerInset = textContainerInset
        textView.textContainer.lineFragmentPadding = 0.0
        textView.textColor = UIColor.black.withAlphaComponent(0.54)
        textView.tintColor = .blue
    }

    private func updatePlaceholderVisibility() {
        self.placeholderTextView?.isHidden = self.placeholderIsHidden
    }

}


extension MultilineTextTableViewCell {

    func resignFirstResponder() {
        self.contentTextView?.resignFirstResponder()
    }

    func becomeFirstResponder() {
        self.contentTextView?.becomeFirstResponder()
    }

}


extension MultilineTextTableViewCell: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        self.placeholderTextView?.isHidden = true
        self.delegate?.multilineTextTableViewCellDidBeginEditing(self)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.updatePlaceholderVisibility()
        self.delegate?.multilineTextTableViewCellDidEndEditing(self)
    }

    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.multilineTextTableViewCellDidChange(self)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return self.delegate?.multilineTextTableViewCell(self, shouldChangeTextIn: range, replacementText: text) ?? true
    }

}



private protocol TextStyle {
    var font: UIFont { get }
    var attributes: [NSAttributedString.Key: Any] { get }
}


private struct MultilineTextTableViewCellContentTextStyle: TextStyle {

    var font: UIFont {
        /*
        let size: CGFloat = 15.0
        let font = UIFont(name: "Roboto-Regular", size: size)

        return font ?? .systemFont(ofSize: size)
        */
        return UIFont.systemFont(ofSize: 17, weight: .regular)
    }

    var attributes: [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.0

        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.font,
            .kern: 0.58,
            .paragraphStyle: paragraphStyle
        ]

        return attributes
    }

}
