import Foundation
import UIKit
import CocoaLumberjack

struct ImageStorageService {
    static private func directory(username: String) -> URL {
        return FileManager.default.documentsDirectory
                .appendingPathComponent(username)
                .appendingPathComponent("local-images")
    }

    let directory: URL

    init(for user: UserProfile) {
        directory = Self.directory(username: user.email)

        // create folder if not exist
        if !FileManager.default.directoryExistsAtPath(directory) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    func saveImage(_ image: UIImage, name: String = newUUID) throws -> URL {
        DDLogVerbose("")
        guard let data = image.jpegData(compressionQuality: 1) else {
            //FIXME: error type
            throw NSError(domain: "no jpeg data", code: -1)
        }
        let imageURL = directory.appendingPathComponent(name).appendingPathExtension("jpg")
        try data.write(to: imageURL)
        return imageURL
    }

    func removeImage(at url: URL) throws {
        DDLogVerbose("")
        guard FileManager.default.fileExists(atPath: url.path) else {
            //FIXME: error type
            throw NSError(domain: "file not exist", code: -1)
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
