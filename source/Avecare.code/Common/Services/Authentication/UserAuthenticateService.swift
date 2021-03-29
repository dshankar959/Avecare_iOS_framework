import Foundation
import CocoaLumberjack



final class UserAuthenticateService: IndicatorProtocol {

    static let shared = UserAuthenticateService()


    // MARK: - Sign-in
    func signIn(userCredentials: UserCredentials, completion:@escaping (AppError?) -> Void) {
/*
        // -
        #if DEBUG && targetEnvironment(simulator)
        // ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~
        // Impersonate a real client on Prod. server.  Comment out this section to disable.
        // Here be dragons! Tread lightly.
        // Must do a fresh install.
        let userCredentials = UserCredentials(email: "holly.lysyshinmohawkcollege.ca", password: "")
        let userProfile = UserProfile(userCredentials: userCredentials)
        let clientToken = APIToken(withToken: "995dd05ae80e2c9e065bdbfeb11f555ddad5527f",
                                   accountType: "guardian",
                                   accountTypeId: "d2311532-0ef9-4659-9178-e73fef871cd1",
                                   isFakeToken: false)
        appSettings.serverURLstring = ServerURLs.production.description // prod. server

        // then.. login as the client to test their DB.
        DDLogError("~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~")
        DDLogError(" ATTENTION!  Testing user inception.")
        DDLogError("~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~\n")

        // Override any previous session
        appDelegate._session = Session(token: clientToken, userProfile: userProfile)

        self.onSignInLaunchCheck()

        DDLogWarn("⚠️ - override  - ⚠️")
        // override
        appSettings.rememberLastUsername = false
        appSettings.enableSyncUp = false
        appSettings.enableSyncDown = true

        RLMAccountInfo.saveAccountInfo(for: clientToken.accountType, with: clientToken.accountTypeId)

        if appSettings.isFirstLogin() {
            do {  // some DB defaults.
                let data = try Data(resource: R.file.formTemplateRowsJson)
                let log = try JSONDecoder().decode([RLMLogChooseRow].self, from: data)

                // Add default rows, et al.
                RLMLogChooseRow.createOrUpdateAll(with: log)

            } catch {
                DDLogError("JSON Decoding error = \(error)")
                fatalError("JSON Decoding error = \(error)")
            }
        }

        completion(nil)
        return

        #endif
        // MARK: -
*/

        // MARK: -
        showActivityIndicator(withStatus: NSLocalizedString("authenticate_signing_in", comment: ""))

        UserAPIService.authenticateUserWith(userCreds: userCredentials) { [weak self] result in
            self?.hideActivityIndicator()

            switch result {
            case .success(let token):
                DDLogVerbose("Successful login.  👍  [withToken = \(token)]")
                let userProfile = UserProfile(userCredentials: userCredentials)

                // Update session and data to construct valid session
                appDelegate._session = Session(token: token, userProfile: userProfile)
                appSettings.lastUsername = userCredentials.username
                UserKeychainService.saveUserProfile(userProfile)
                UserKeychainService.saveCurrentToken(token: token)

                self?.onSignInLaunchCheck()

                RLMAccountInfo.saveAccountInfo(for: token.accountType, with: token.accountTypeId)

                if appSettings.isFirstLogin() {
                    do {  // some DB defaults.
                        let data = try Data(resource: R.file.formTemplateRowsJson)
                        let log = try JSONDecoder().decode([RLMLogChooseRow].self, from: data)

                        // Add default rows, et al.
                        RLMLogChooseRow.createOrUpdateAll(with: log)

                    } catch {
                        DDLogError("JSON Decoding error = \(error)")
                        fatalError("JSON Decoding error = \(error)")
                    }
                }

                completion(nil)

            case .failure(let error):
                completion(error)
            }
        }
    }


    private func onSignInLaunchCheck() {
        DDLogInfo("")

        DALConfig.userRealmFileURL = nil    // reset DB access.

        appSettings.userLoginCount += 1
        if appSettings.isFirstLogin() {
            /// First time, fresh install, new user, etc.  Set defaults.
            appSettings.rememberLastUsername = true
            appSettings.enableSyncUp = true
            appSettings.enableSyncDown = true
        }

        /*
         #if DEBUG
         if !appSettings.isFirstLogin() {
         // Control syncing.
         // If you've already synced down the data you want to work with, there is no need to keep syncing it down.
         // So you can disable syncing to speed-up coding.
         appSettings.enableSyncUp = false
         appSettings.enableSyncDown = false
         }
         #endif
         */

        /// Track app version in case we need to perform any custom migration upon an update.
        let previousAppVersion = appSettings.appVersion ?? ""
        let currentAppVersion = Bundle.main.versionNumber

        let versionCompare = previousAppVersion.compare(currentAppVersion, options: .numeric)
        if versionCompare == .orderedSame {
            DDLogVerbose("same == version")
            // nothing to do.

        } else if versionCompare == .orderedAscending {
            /// previousAppVersion < currentAppVersion
            DDLogVerbose("(previousAppVersion [\(previousAppVersion)] < newAppVersion [\(currentAppVersion)])  [UPGRADE!]  🌈")
            DDLogVerbose("(.. or it's a fresh install...)")

            // critical upgrades..

            appSettings.enableSyncUp = true
            appSettings.enableSyncDown = true

        } else if versionCompare == .orderedDescending {
            // previousAppVersion > currentAppVersion
            DDLogVerbose("🤔 - from the future?")
        }

        // done.
        appSettings.appVersion = Bundle.main.versionNumber
    }


    // MARK: - Sign-out

    func signOut(completion:@escaping (AppError?) -> Void) {
        showActivityIndicator(withStatus: NSLocalizedString("authenticate_signing_out", comment: ""))
        UserAPIService.logout { [weak self] result in
            switch result {
            case .success(let message):
                DDLogVerbose("Logged out from the server successfully.✅  [with status code = \(message)]")
                UserKeychainService.saveCurrentToken(token: nil)
                self?.resetSyncEngine {
                    completion(nil)
                }
            case .failure(let error):
                self?.hideActivityIndicator()
                DDLogError("\(error)")
                completion(error)
            }
        }
    }


    func resetSyncEngine(completion:@escaping () -> Void) {
        syncEngine.stopSyncTimer()
        syncEngine.isSyncCancelled = true

        if syncEngine.isSyncing {
            DDLogInfo("Waiting for sync to complete.")
            syncEngine.syncAll { [weak self] error in
                DDLogInfo("Sync completed.")
                self?.resetApp {
                    completion()
                }
            }
        } else {
            resetApp {
                completion()
            }
        }
    }


    private func resetApp(completion:@escaping () -> Void) {
        DDLogInfo("Resetting app.")
        appDelegate._syncEngine = SyncEngine()
        appDelegate._appSettings = AppSettings()
        appDelegate._session = Session()

        // give extra time for animations and 'writes' to settle.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.hideActivityIndicator()
            completion()
        }
    }

}
