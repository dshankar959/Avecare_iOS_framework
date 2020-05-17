import Foundation
import CocoaLumberjack



private let kUseBiometricAuthenticationKey = "useBiometricAuthentication"
private let kRememberLastUsernameKey = "rememberLastUsername"
private let kLastUsernameKey = "lastUsername"
private let kUserLoginCountKey = "loginCount"
private let kUserLastLoginDateKey = "lastLoginDate"
private let kAppVersionKey = "appVersion"

// <internal>
private let kEnableSyncUpKey = "enableSyncUp"
private let kEnableSyncDownKey = "enableSyncDown"


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

    func isFirstLogin() -> Bool {
        if userLoginCount <= 1 {
            DDLogDebug("🆕  First Launch!  🆕")

            let defaults = userDefaults(for: appSession.userProfile)
            defaults.set(Date.ISO8601StringFromDate(Date()), forKey: kUserLastLoginDateKey)

            return true
        } else {
            return false
        }
    }

    var userLoginCount: Int {
        get {
            return userDefaults(for: appSession.userProfile).integer(forKey: kUserLoginCountKey)
        }
        set (newValue) {
            DDLogDebug("UserLoginCount: \(newValue)")

            let defaults = userDefaults(for: appSession.userProfile)
            defaults.set(newValue, forKey: kUserLoginCountKey)
            defaults.set(Date.local24hrFormatISO8601StringFromDate(Date()), forKey: kUserLastLoginDateKey)
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

    var enableSyncUp: Bool {
        get {
            return userDefaults(for: appSession.userProfile).bool(forKey: kEnableSyncUpKey)
        }
        set (newValue) {
            DDLogDebug("enable Sync Up: \(newValue)")

            let defaults = userDefaults(for: appSession.userProfile)
            defaults.set(newValue, forKey: kEnableSyncUpKey)
            defaults.synchronize()
        }
    }


    var enableSyncDown: Bool {
        get {
            return userDefaults(for: appSession.userProfile).bool(forKey: kEnableSyncDownKey)
        }
        set (newValue) {
            DDLogDebug("enable Sync Down: \(newValue)")

            let defaults = userDefaults(for: appSession.userProfile)
            defaults.set(newValue, forKey: kEnableSyncDownKey)
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
