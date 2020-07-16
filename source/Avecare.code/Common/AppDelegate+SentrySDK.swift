import UIKit
import CocoaLumberjack
import Sentry
import ZIPFoundation



extension AppDelegate {

    func setupSentrySDK() {
        #if DEBUG || targetEnvironment(simulator)
            DDLogVerbose("⚠️  #DEBUG build ❕ Sentry SDK DISABLED. ❕")
        #else
            DDLogVerbose("⚠️  #RELEASE build❕ Sentry SDK ENABLED.  ⚠️")
            DDLogDebug("SentrySDK dsn: \(Bundle.main.sentrySDKdsn)")

            SentrySDK.start { options in
                options.dsn = Bundle.main.sentrySDKdsn
                options.beforeSend = { event in
                    DDLogDebug("sentry event: \(event)")
                    if event.level == .error || event.level == .fatal {
                        DDLogDebug("sentry event.level: \(event.level.rawValue)")
                        DDLogError("A crash occured.  🤔")
                    }

                    return event
                }
//                options.debug = true
                options.logLevel = SentryLogLevel.verbose
                options.enableAutoSessionTracking = true
                options.attachStacktrace = true
                options.sessionTrackingIntervalMillis = 5_000}
        #endif
    }


}


extension AppDelegate {

    func zipLogfiles(completion:@escaping (_ zipFilename: String?) -> Void) {
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
            completion(nil)
            return
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
                    completion(nil)
                    return
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
            completion(nil)
            return
        }

        completion(zippedFilename)
    }

}
