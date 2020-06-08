import UIKit
import CocoaLumberjack
import PDFKit


struct ImageStorageService {

    let directory: URL

    init() {
        directory = userAppDirectory.appendingPathComponent("images")
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
    
    func savePDF(_ pdf: PDFDocument, name: String = newUUID) -> URL {
        DDLogVerbose("savePDF name: \(name)")
        let pdfURL = directory.appendingPathComponent(name).appendingPathExtension("pdf")
        pdf.write(to: pdfURL)
        return pdfURL
//        do {
//            try
//        } catch {
//         DDLogError("⚠️ Error saving pdf! 🤨")
//         throw NSError(domain: "Error saving pdf!", code: -1)
//         }

    }


    func saveImage(_ remoteImageURL: URL, name: String = newUUID) throws -> URL {
        DDLogVerbose("Loading image from: \(remoteImageURL)")

        let data = try Data(contentsOf: remoteImageURL)
        let localImageURL = directory.appendingPathComponent(name).appendingPathExtension("jpg")
        try data.write(to: localImageURL)

        DDLogVerbose("Did save image to: \(localImageURL)")
        return localImageURL
    }
    
    func savePDF(_ remotePDFURL: URL, name: String = newUUID) throws -> URL {
        DDLogVerbose("Loading pdf from: \(remotePDFURL)")

        let data = try Data(contentsOf: remotePDFURL)
        let localImageURL = directory.appendingPathComponent(name).appendingPathExtension("pdf")
        try data.write(to: localImageURL)

        DDLogVerbose("Did save pdf to: \(localImageURL)")
        return localImageURL
    }


    func removeFile(at url: URL) throws {
        DDLogVerbose("")

        guard FileManager.default.fileExists(atPath: url.path) else {
            DDLogError("⚠️ Missing image file.")
            throw NSError(domain: "⚠️ Missing image file", code: -1)
        }

        FileManager.default.removeFileAt(url)
    }


    func imageURL(name: String, type: String) -> URL? {
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
