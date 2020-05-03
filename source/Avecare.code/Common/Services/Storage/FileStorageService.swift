import Foundation
import CocoaLumberjack

struct FileStorageService {

    static func appDirectory(for user: UserProfile) -> URL? {
        if user.email.isEmpty {
            DDLogError("Empty email")
            return nil
        }

        let finalDirectory = FileManager.default.applicationSupportDirectory.appendingPathComponent(user.email).path

        return FileManager.default.createDirectory(URL(fileURLWithPath: finalDirectory))
    }

    static func documentsDirectory(for user: UserProfile) -> URL? {
        if user.email.isEmpty {
            DDLogError("Empty email")
            return nil
        }

        let finalDirectory = FileManager.default.documentsDirectory.appendingPathComponent(user.email).path

        return FileManager.default.createDirectory(URL(fileURLWithPath: finalDirectory))
    }

    static func cachesDirectory(for user: UserProfile) -> URL? {
        if user.email.isEmpty {
            DDLogError("Empty email")
            return nil
        }

        let finalDirectory = FileManager.default.cachesDirectory.appendingPathComponent(user.email).path

        return FileManager.default.createDirectory(URL(fileURLWithPath: finalDirectory))
    }

    static func createTempDirectory() -> URL? {
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let finalDirectory = FileManager.default.tmpDirectory.appendingPathComponent(folderName).path

        return FileManager.default.createDirectory(URL(fileURLWithPath: finalDirectory))
    }

    static var userAppDirectory: URL {
        if appSession.isSignedIn() || appSession.token.isFake {
            let currentUser = appSession.userProfile
            return FileStorageService.appDirectory(for: currentUser)!
        } else {    // nope
            DDLogError("No active session.  Please sign-in first.")
            fatalError("No active session.  Please sign-in first.")
        }
    }

}
