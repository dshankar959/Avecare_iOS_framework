import Moya
import CocoaLumberjack
import ZIPFoundation



struct UserFeedbackRequestModel {

    let id: String
    let serverLastUpdated: Date? = nil
    let clientLastUpdated: Date = Date()
    let title: String
    let comments: String
    var logfilesURL: URL? = nil


    private enum CodingKeys: String, CodingKey {
        case id
        case serverLastUpdated = "updatedAt"
        case clientLastUpdated = "createdAt"
        case title
        case comments = "description"
        case fileAttachment = "file"
    }

    init(title: String, comments: String, includeLogfiles: Bool) {
        self.id = newUUID
        self.title = title
        self.comments = comments

        if includeLogfiles {
            self.logfilesURL = zipLogfiles()
        }
    }

}


extension UserFeedbackRequestModel: MultipartEncodable {

    var formData: [Moya.MultipartFormData] {
        var data = [Moya.MultipartFormData]()

        if let value = id.data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.id.rawValue))
        }

        if let value = title.data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.title.rawValue))
        }

        if let value = comments.data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.comments.rawValue))
        }

        if let value = Date.ISO8601StringFromDate(clientLastUpdated).data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.clientLastUpdated.rawValue))
        }

        if let url = logfilesURL {
            data.append(.init(provider: .file(url), name: CodingKeys.fileAttachment.rawValue))
        }

        return data
    }

}


extension UserFeedbackRequestModel {

    private func zipLogfiles() -> URL? {
        var destinationURL: URL? = nil
        var tempDirectory: URL? = nil

        let fileManager = FileManager()
        let profile = appSession.userProfile
        let email = profile.email
        let zippedFilename = "\(email)_\(Date.shortISO8601FileStringFromDate(Date())).zip"
        tempDirectory = FileStorageService.createTempDirectory()

        // Start with the log files.
        let sourceURL = appDelegate._loggerDirectory
        destinationURL = tempDirectory
        destinationURL?.appendPathComponent(zippedFilename)

        do {
            try fileManager.zipItem(at: sourceURL, to: destinationURL!)
            DDLogVerbose("zipped log files in: \(zippedFilename)")
        } catch {
            DDLogError("Creation of ZIP archive failed with error:\(error)")
            return nil
        }

        // Add Preferences (.plist) files
        let preferencesDirectory = FileManager.default.preferencesDirectory

        if let plistFiles = FileManager.default.getAllFilesIn(preferencesDirectory) {
            for plist in plistFiles {
                do {
                    if let archive = Archive(url: destinationURL!, accessMode: .update) {
                        try archive.addEntry(with: plist.lastPathComponent, relativeTo: preferencesDirectory)
                    }

                } catch {
                    DDLogError("Creation of ZIP archive failed with error:\(error)")
                    return nil
                }
            }
        }

        // Add DB file to zip package.
        do {
            if let archive = Archive(url: destinationURL!, accessMode: .update) {
                try archive.addEntry(with: DALConfig.realmStoreName, relativeTo: userAppDirectory)
                DDLogVerbose("zipped realm DB file in: \(zippedFilename)")
            }
        } catch {
            DDLogError("🤔 Adding DB entry to ZIP archive failed with error:\(error)")
            return nil
        }

        let zippedFilenameURL = tempDirectory?.appendingPathComponent(zippedFilename)

        return zippedFilenameURL
    }

}
