import UIKit
import CocoaLumberjack



struct ImageStorageService {

    let directory: URL

    init() {
        directory = userAppDirectory.appendingPathComponent("images")
        _ = FileManager.default.createDirectory(directory)
    }


    func saveImage(_ image: UIImage, name: String = newUUID) throws -> URL {
        DDLogVerbose("")

        if let data = image.jpegData(compressionQuality: 1) {
            let imageURL = directory.appendingPathComponent(name).appendingPathExtension("jpg")
            try data.write(to: imageURL)
            return imageURL
        }

        DDLogError("⚠️ Error saving image! 🤨")
        throw NSError(domain: "Error saving image!  (no jpeg data? 🤨)", code: -1)
    }


    func saveImage(_ remoteImageURL: URL, name: String = newUUID) throws -> URL {
        DDLogVerbose("Loading image from: \(remoteImageURL)")

        let data = try Data(contentsOf: remoteImageURL)
        let localImageURL = directory.appendingPathComponent(name).appendingPathExtension("jpg")
        try data.write(to: localImageURL)

        DDLogVerbose("Did save image to: \(localImageURL)")
        return localImageURL
    }


    func removeImage(at url: URL) throws {
        DDLogVerbose("")

        guard FileManager.default.fileExists(atPath: url.path) else {
            DDLogError("⚠️ Missing image file.")
            throw NSError(domain: "⚠️ Missing image file", code: -1)
        }

        FileManager.default.removeFileAt(url)
    }


    func imageURL(name: String) -> URL? {
        let imageURL = directory.appendingPathComponent(name).appendingPathExtension("jpg")
        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            return nil
        }

        return imageURL
    }

}
