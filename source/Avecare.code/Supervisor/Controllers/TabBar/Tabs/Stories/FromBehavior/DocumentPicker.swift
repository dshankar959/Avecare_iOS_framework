import UIKit
import PDFKit
import MobileCoreServices

class DocumentPicker: NSObject {
    private var pickerController: UIDocumentPickerViewController?
    private weak var presentationController: UIViewController?
    private weak var delegate: DocumentDelegate?
    private var documents = [Document]()
    init(presentationController: UIViewController, delegate: DocumentDelegate) {
        super.init()
        self.presentationController = presentationController
        self.delegate = delegate
    }
    public func pickDocuments() {
        self.pickerController = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String, kUTTypeImage as String], in: .open)
        self.pickerController!.delegate = presentationController as? UIDocumentPickerDelegate
        self.pickerController!.allowsMultipleSelection = false
        self.pickerController!.modalPresentationStyle = .fullScreen
        self.presentationController?.present(self.pickerController!, animated: true)
    }
}

extension DocumentPicker: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("CAME HERE")
        guard let url = urls.first else {
            return
        }
        documentFromURL(pickedURL: url)
        self.delegate?.didPickDocuments(documents: documents, url: url)
    }
   
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.delegate?.docPickerCancelled()
    }
    private func documentFromURL(pickedURL: URL) {
        let shouldStopAccessing = pickedURL.startAccessingSecurityScopedResource()
        defer {
            if shouldStopAccessing {
                pickedURL.stopAccessingSecurityScopedResource()
            }
        }
        NSFileCoordinator().coordinate(readingItemAt: pickedURL, error: NSErrorPointer.none) { (folderURL) in
            let document = Document(fileURL: pickedURL)
            self.documents.append(document)
        }
    }
}

protocol DocumentDelegate: class {
    func didPickDocuments(documents: [Document]?, url: URL)
    func docPickerCancelled()
}

class Document: UIDocument {
    var data: Data?
    override func contents(forType typeName: String) throws -> Any {
        guard let data = data else { return Data() }
        return try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
    }
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        guard let data = contents as? Data else { return }
        self.data = data
    }
}

func generatePdfThumbnail(of thumbnailSize: CGSize, for documentUrl: URL, atPage pageIndex: Int) -> UIImage? {
    let pdfDocument = PDFDocument(url: documentUrl)
    let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
    return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
}
