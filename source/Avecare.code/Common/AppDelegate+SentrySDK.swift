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
                        DDLogWarn("A crash occured.  🤔")

                        if let userEmail = event.user?.email {
                            // Fake out a session for the crashed user.
                            let userCredentials = UserCredentials(email: userEmail, password: "")
                            let userProfile = UserProfile(userCredentials: userCredentials)
                            var token = APIToken()
                            token.isFake = true
                            let session = Session(token: token, userProfile: userProfile)

                            UserAPIService.submitUserFeedback(for: session,
                                                              comments: "Sentry detected a crash.  🤔",
                                                              withLogfiles: true) { error in
                                if let error = error {
                                    DDLogError("submitUserFeedback error = \(error)")
                                }
                            }
                        }
                    }

                    return event
                }
//                options.debug = true
                options.logLevel = SentryLogLevel.verbose
                options.enableAutoSessionTracking = true
                options.attachStacktrace = true
                options.sessionTrackingIntervalMillis = 5_000
            }

        if let reportCount = SentryCrash.sharedInstance()?.reportCount {
            DDLogWarn("Pending crash reports = \(reportCount)")
        }

        #endif
    }


}
