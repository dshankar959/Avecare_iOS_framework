import UIKit
import CocoaLumberjack
import FirebaseCrashlytics



extension AppDelegate {

    func analyzeCrashlytics() {
        // Detect when a crash happens during your app's last run.
        if Crashlytics.crashlytics().didCrashDuringPreviousExecution() {
            DDLogWarn("🤔 app crashed during previous execution.")
        }
    }


}
