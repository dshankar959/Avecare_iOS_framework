import UIKit
import Kingfisher



struct SubjectDetailsPhotoViewModel: CellViewModel {
    typealias CellType = SubjectDetailsPhotoView

    struct Action {
        var onTextChange: ((CellType) -> Void)?
        var onPhotoTap: ((CellType) -> Void)?
    }

    var image: URL? = nil
    var note: String?
    var title: String
    var action: Action? = nil

    let isEditable: Bool

    func setup(cell: CellType) {
        cell.textViewTitle.text = title
        cell.textView.text = note
        cell.setImage(image)
        cell.updatePlaceholderVisibility()

        if isEditable {
            cell.onTextChange = action?.onTextChange
            cell.onPhotoTap = action?.onPhotoTap
            cell.textView.isEditable = true
        } else {
            cell.textView.isEditable = false
        }
    }
}


class SubjectDetailsPhotoView: BaseXibView {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewTitle: UILabel!
    @IBOutlet weak var textViewPlaceholder: UILabel!
    @IBOutlet weak var imagePlaceholderView: UIView!

    var onTextChange: ((SubjectDetailsPhotoView) -> Void)?
    var onPhotoTap: ((SubjectDetailsPhotoView) -> Void)?

    var characterLimit = 140

    override func setup() {
        super.setup()

        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

        textContainerView.layer.borderWidth = 0.5
        textContainerView.layer.cornerRadius = 4
        textContainerView.layer.masksToBounds = true
        textContainerView.layer.borderColor = R.color.darkText()?.withAlphaComponent(0.1).cgColor
    }

    @IBAction func didTapPhotoGesture(_ recognizer: UITapGestureRecognizer) {
        onPhotoTap?(self)
    }

    func setImage(_ url: URL?) {
        if let url = url {
            imagePlaceholderView.isHidden = true
            if url.absoluteString.isFilePath {
                photoImageView.image = UIImage(contentsOfFile: url.path)
            } else {
                photoImageView.kf.setImage(with: url)
            }

        } else {
            photoImageView.image = nil
            imagePlaceholderView.isHidden = false
        }
    }
}

extension SubjectDetailsPhotoView: UITextViewDelegate {

    func updatePlaceholderVisibility() {
        textViewPlaceholder.isHidden = textView.text.count > 0
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        textViewPlaceholder.isHidden = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }

    public func textViewDidChange(_ textView: UITextView) {
        onTextChange?(self)
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentLength = textView.text.count
        let addition = text.count - range.length

        return (currentLength + addition) <= characterLimit
    }

}
