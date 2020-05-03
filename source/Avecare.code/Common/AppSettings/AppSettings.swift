import Foundation
import CocoaLumberjack

// MODEL.

private let kUseBiometricAuthenticationKey = "useBiometricAuthentication"
private let kRememberLastUsernameKey = "rememberLastUsername"
private let kLastUsernameKey = "lastUsername"
private let khasBeenLaunchedBeforeKey = "hasBeenLaunchedBeforeFlag"
private let kAppVersionKey = "appVersion"

// Singleton
class AppSettings {

    var isTesting = false
    var isHTTPlogging = true            // lots of extra debug info.

    // MARK: -

    private func userDefaults(for profile: UserProfile?) -> UserDefaults {
        if let user = profile {
            return UserDefaults(suiteName: user.email)!     // user specific plist file
        } else {
            return UserDefaults.standard                    // global (app) specific plist file
        }
    }

    var serverURLstring: String {
        let url = Servers().defaultRuntimeURLstring()
        return url
    }

    var useBiometricAuthentication: Bool {
        get {
            return userDefaults(for: nil).bool(forKey: kUseBiometricAuthenticationKey)
        }
        set (newValue) {
            DDLogDebug("useBiometricAuthentication: \(newValue)")
            let defaults = userDefaults(for: nil)
            defaults.set(newValue, forKey: kUseBiometricAuthenticationKey)
        }
    }

    var rememberLastUsername: Bool {
        get {
            return userDefaults(for: nil).bool(forKey: kRememberLastUsernameKey)
        }
        set (newValue) {
            DDLogDebug("rememberLastUsername: \(newValue)")
            let defaults = userDefaults(for: nil)
            defaults.set(newValue, forKey: kRememberLastUsernameKey)

            if newValue == true {
                if !appSession.userProfile.isEmpty() {
                    self.lastUsername = appSession.userProfile.email
                }
            }

        }
    }

    var lastUsername: String? {
        get {
            return userDefaults(for: nil).string(forKey: kLastUsernameKey)
        }
        set (newValue) {
            DDLogDebug("new lastUsername: \(newValue ?? "<nil>")")

            let defaults = userDefaults(for: nil)
            defaults.set(appSession.userProfile.email, forKey: kLastUsernameKey)

        }
    }

    func isFirstLaunch() -> Bool {
        if hasBeenLaunchedBeforeFlag == false {
            DDLogDebug("First Launch!  🆕")
            hasBeenLaunchedBeforeFlag = true
            return true
        } else {
            return false
        }
    }

    private var hasBeenLaunchedBeforeFlag: Bool {
        get {
            return userDefaults(for: appSession.userProfile).bool(forKey: khasBeenLaunchedBeforeKey)
        }
        set (newValue) {
            DDLogDebug("hasBeenLaunchedBefore: \(newValue)")

            let defaults = userDefaults(for: appSession.userProfile)
            defaults.set(newValue, forKey: khasBeenLaunchedBeforeKey)
        }
    }

    var appVersion: String? {
        get {
            return userDefaults(for: appSession.userProfile).string(forKey: kAppVersionKey)
        }
        set (newValue) {
            DDLogDebug("\"appVersion\": \(newValue ?? "nil")")

            let defaults = userDefaults(for: appSession.userProfile)
            defaults.set(newValue, forKey: kAppVersionKey)
            defaults.synchronize()
        }
    }

    // MARK: -
    init() {
        if NSClassFromString("XCTest") != nil {
            isTesting = true
        }
//        // #force to test stubs
//        isTesting = true
    }

    deinit {
        DDLogWarn("\(self)")
    }

}
