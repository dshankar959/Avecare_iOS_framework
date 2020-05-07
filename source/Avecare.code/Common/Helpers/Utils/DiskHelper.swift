import Foundation
import CocoaLumberjack



// https://stackoverflow.com/a/44499481/7599
class DiskHelper {

    /// - Parameter filePath: prevented iCloud backup filePath.
    func preventiCloudBackupForFile(urlPath: URL?) {
        do {
            if let url = urlPath {
                try FileManager.default.addSkipBackupAttributeToItemAtURL(url: url as NSURL)
            }
        } catch {
            DDLogError("Error: \(error)")
        }
    }

}
