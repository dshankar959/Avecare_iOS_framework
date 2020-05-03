import UIKit
import CocoaLumberjack



extension AppDelegate {

    func setupLoggingFramework() {
        // #disable noisy `Warnings` only.
        let ddlogLevelFlags = DDLogFlag.error.rawValue |
                              DDLogFlag.debug.rawValue |
                              DDLogFlag.info.rawValue  |
                              DDLogFlag.verbose.rawValue

        dynamicLogLevel = DDLogLevel.init(rawValue: ddlogLevelFlags)!

        // console
        if let ttyLogger = DDTTYLogger.sharedInstance {
            DDLog.add(ttyLogger) // TTY = Xcode console
            ttyLogger.logFormatter = MyCustomFormatter()
        }

        // file
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.maximumFileSize = (1 * 1048576);   // ~1MB
        fileLogger.logFileManager.maximumNumberOfLogFiles = 50
        fileLogger.logFormatter = MyCustomFormatter()
        DDLog.add(fileLogger)

        if let currentLogFileInfo = fileLogger.currentLogFileInfo {
            appDelegate._loggerDirectory = URL(fileURLWithPath: currentLogFileInfo.filePath)
            appDelegate._loggerDirectory.deleteLastPathComponent()  // directory only
            // mark this space to make reading log files easier in locating a starting position.
            DDLogInfo("=============================================================================================================")
            DDLogInfo("log files location: \(appDelegate._loggerDirectory)")
        }

    }


}
