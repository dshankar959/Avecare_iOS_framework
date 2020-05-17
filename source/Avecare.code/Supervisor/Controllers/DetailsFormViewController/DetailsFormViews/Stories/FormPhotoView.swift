import Foundation
import UIKit
import Kingfisher

struct FormPhotoViewModel: CellViewModel {
    typealias CellType = FormPhotoView

    struct Action {
        let onTextChange: ((CellType, String?) -> Void)?
        let onPhotoTap: ((CellType) -> Void)?
    }

    let photoURL: URL?
    let caption: String?
    let placeholder: String
    let isEditable: Bool

    var action: Action?

    func setup(cell: CellType) {
        if isEditable {
            cell.onChange = action?.onTextChange
            cell.onPhotoTap = action?.onPhotoTap
        }

        cell.photoImageView.kf.setImage(with: photoURL, placeholder: R.image.noPhotoPlaceholder())
        cell.textView.text = caption
        cell.textViewPlaceholder.text = placeholder

        cell.updatePlaceholderVisibility()

        cell.textView.isUserInteractionEnabled = isEditable
    }
}

class FormPhotoView: BaseXibView {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewPlaceholder: UILabel!

    var onChange: ((FormPhotoView, String?) -> Void)?
    var onPhotoTap: ((FormPhotoView) -> Void)?

    override func setup() {
        super.setup()
        let font: UIFont = .systemFont(ofSize: 14)
        textViewPlaceholder.font = font
        textView.font = font
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }

    func updatePlaceholderVisibility() {
        textViewPlaceholder.isHidden = textView.text.count > 0
    }

    @IBAction func didTapPhotoImageView(_ sender: UITapGestureRecognizer) {
        onPhotoTap?(self)
    }
}

extension FormPhotoView: UITextViewDelegate {
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
