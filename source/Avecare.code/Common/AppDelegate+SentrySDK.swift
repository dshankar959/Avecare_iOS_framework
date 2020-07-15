import UIKit
import CocoaLumberjack
import Sentry



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
