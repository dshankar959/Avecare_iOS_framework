import UIKit
import CocoaLumberjack



struct ImageStorageService {

    let directory: URL


    init() {
        directory = userAppDirectory.appendingPathComponent("images")
        _ = FileManager.default.createDirectory(directory)
    }


    func saveImage(_ image: UIImage) throws -> URL? {
        if let data = image.jpegData(compressionQuality: 1) {
            let uuid = newUUID
            let imageURL = directory.appendingPathComponent(uuid).appendingPathExtension("jpg")
            try data.write(to: imageURL)
            return imageURL
        }

        DDLogError("⚠️ Error saving image!")
        return nil
    }


    func removeImage(at url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            DDLogError("⚠️ Missing image file.")
            throw NSError(domain: "⚠️ Missing image file", code: -1)
        }

        FileManager.default.removeFileAt(url)
    }

}
