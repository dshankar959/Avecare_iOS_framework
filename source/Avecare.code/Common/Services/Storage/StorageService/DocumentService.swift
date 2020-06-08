import UIKit
import CocoaLumberjack
import PDFKit


struct DocumentService {

    let directory: URL

    init() {
        directory = userAppDirectory.appendingPathComponent("documents")
        _ = FileManager.default.createDirectory(directory)
    }


    func saveImage(_ image: UIImage, name: String = newUUID) throws -> URL {
        DDLogVerbose("saveImage name: \(name)")

        if let data = image.jpegData(compressionQuality: 1) {
            let imageURL = directory.appendingPathComponent(name).appendingPathExtension("jpg")
            try data.write(to: imageURL)
            return imageURL
        }

        DDLogError("⚠️ Error saving image! 🤨")
        throw NSError(domain: "Error saving image!  (no jpeg data? 🤨)", code: -1)
    }

    func savePDF(_ pdf: PDFDocument, name: String = newUUID) {
        DDLogVerbose("savePDF name: \(name)")
        let pdfURL = directory.appendingPathComponent(name).appendingPathExtension("pdf")
        pdf.write(to: pdfURL)
    }


    func saveRemoteFile(_ remoteFileURL: URL, name: String = newUUID, type: String) throws -> URL {
        DDLogVerbose("Loading file from: \(remoteFileURL)")

        let data = try Data(contentsOf: remoteFileURL)
        let localImageURL = directory.appendingPathComponent(name).appendingPathExtension(type)
        try data.write(to: localImageURL)

        DDLogVerbose("Did save file to: \(localImageURL)")
        return localImageURL
    }

    func removeFile(at url: URL) throws {
        DDLogVerbose("")

        guard FileManager.default.fileExists(atPath: url.path) else {
            DDLogError("⚠️ Missing file.")
            throw NSError(domain: "⚠️ Missing file", code: -1)
        }

        FileManager.default.removeFileAt(url)
    }


    func fileURL(name: String, type: String) -> URL? {
        let imageURL = directory.appendingPathComponent(name).appendingPathExtension(type)
        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            return nil
        }

        return imageURL
    }

    public func getImageForPDF(of thumbnailSize: CGSize, for documentUrl: URL, atPage pageIndex: Int) -> UIImage? {
               let pdfDocument = PDFDocument(url: documentUrl)
               let pdfDocumentPage = pdfDocument?.page(at: pageIndex)
               return pdfDocumentPage?.thumbnail(of: thumbnailSize, for: PDFDisplayBox.trimBox)
    }
}
