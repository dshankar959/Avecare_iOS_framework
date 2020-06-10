import UIKit
import BSImagePicker
import Photos
import CocoaLumberjack
import PDFKit
import MobileCoreServices



extension StoriesDataProvider {

    func getPDFThumbViewModel(for story: RLMStory) -> PDFThumbViewModel {
        let service = DocumentService()
        let isSubmitted = story.publishState != .local
        let photoRowAction = PDFThumbViewModel.Action( onPDFTap: { [weak self] view in
            if let url = service.fileURL(name: story.id, type: "pdf") {
                self?.delegate?.gotToPDFDetail(fileUrl: url)
            } else if !isSubmitted {
                self?.showDocumentPicker(from: view, for: story)
            }
            }, onPDFRemove: { [weak self] view in
                self?.removePDFForStory(from: view, for: story)
            })

        return PDFThumbViewModel(pdfURL: story.pdfURL(using: imageStorageService), isEditable: !isSubmitted, action: photoRowAction)
    }

    func removePDFForStory(from view: PDFThumbView, for story: RLMStory) {
        let service = DocumentService()
        if let fileURL = service.fileURL(name: story.id, type: "pdf") {
            do {
                try service.removeFile(at: fileURL)
            } catch {
                DDLogError("\(error)")
            }
        }
        view.photoImageView.image = UIImage.init(named: "no-pdf-placeholder")
        view.removeButton.isHidden = true
        self.updateEditDate(for: story)
        self.delegate?.didUpdateModel(at: IndexPath(row: 0, section: 0), details: false)
    }

    func showDocumentPicker(from view: PDFThumbView, for story: RLMStory) {
        self.delegate?.didTapPDF(story: story, view: view)
    }

    func didPickDocumentsAt(urls: [URL], view: PDFThumbView) {
        guard let url = urls.first else {
            return
        }

        let size = 375 * UIScreen.main.scale
        let service = DocumentService()
        let image = service.getImageForPDF(of: CGSize(width: size, height: size), for: url, atPage: 0)
        let pdf = PDFDocument(url: url)
        // remove previous local pdf
        if let story = selectedStory, let image = image {
            if let fileURL = service.fileURL(name: story.id, type: "pdf") {
                do {
                    try service.removeFile(at: fileURL)
                } catch {
                    DDLogError("\(error)")
                }
            }
            if let pdf = pdf {

                service.savePDF(pdf, name: story.id)
                view.photoImageView.image = image
                view.removeButton.isHidden = false
                self.updateEditDate(for: story)
                self.delegate?.didUpdateModel(at: IndexPath(row: 0, section: 0), details: false)
            }
        }
    }

    func documentPickerWasCancelled() {    }

}