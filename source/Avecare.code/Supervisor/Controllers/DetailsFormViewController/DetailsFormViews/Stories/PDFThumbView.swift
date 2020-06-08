import Foundation
import UIKit
import Kingfisher

struct PDFThumbViewModel: CellViewModel {
    typealias CellType = PDFThumbView

    struct Action {
        let onPDFTap: ((CellType) -> Void)?
        let onPDFRemove: ((CellType) -> Void)?
    }

    let photoURL: URL?
    let isEditable: Bool
    var action: Action?
    
    func setup(cell: CellType) {
        
        cell.onPDFTap = action?.onPDFTap

        if isEditable {
            cell.onPDFRemove = action?.onPDFRemove
        }
        
        let service = DocumentService()
        let size = 375 * UIScreen.main.scale
        
        cell.removeButton.isHidden = true
        
        if let photoURL = photoURL {
            let pdfThumbnail = service.getImageForPDF(of: CGSize(width: size, height: size), for: photoURL, atPage: 0)
            if let pdfThumbnail = pdfThumbnail {
                cell.photoImageView.image = pdfThumbnail
                if isEditable {
                    cell.removeButton.isHidden = false
                }
            }
        }
    }
}

class PDFThumbView: BaseXibView {
    @IBOutlet weak var photoImageView: UIImageView!

    var onChange: ((PDFThumbView, String?) -> Void)?
    var onPDFTap: ((PDFThumbView) -> Void)?
    var onPDFRemove: ((PDFThumbView) -> Void)?

    override func setup() {
        super.setup()
    }

    func updatePlaceholderVisibility() {
    }

    @IBAction func didTapPDFImageView(_ sender: UITapGestureRecognizer) {
        onPDFTap?(self)
    }
    
    @IBOutlet weak var removeButton: UIButton!
    
    @IBAction func didTapRemoveDocument(_ sender: Any) {
        removeButton.isHidden = true
        onPDFRemove?(self)
    }
    
}
