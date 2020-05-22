//
//  UserAthenticateService.swift
//  Avecare
//
//  Created by stephen on 2020-05-21.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import UIKit
import CocoaLumberjack

class UserAthenticateService: IndicatorProtocol {

    static let shared = UserAthenticateService()

    // MARK: - Sing In

    func signIn(userCredentials: UserCredentials, completion:@escaping (AppError?) -> Void) {
        showActivityIndicator(withStatus: "Signing in ...")

        UserAPIService.authenticateUserWith(userCreds: userCredentials) { [weak self] result in
            self?.hideActivityIndicator()

            switch result {
            case .success(let token):
                DDLogVerbose("Successful login.  👍  [withToken = \(token)]")
                let userProfile = UserProfile(userCredentials: userCredentials)

                #if !DEBUG
                // #Crashlytics logging
                Crashlytics.crashlytics().setUserID(userProfile.email)
                #endif

                // Update any previous session, with new token.
                appDelegate._session = Session(token: token, userProfile: userProfile)

                self?.onSignInLaunchCheck()

                RLMAccountInfo.saveAccountInfo(for: token.accountType, with: token.accountTypeId)

                if appSettings.isFirstLogin() {
                    do {  // some DB defaults.
                        //RLMLogChooseRow().clean()   // wipe rows
                        let data = try Data(resource: R.file.logFormRowsJson)
                        let log = try JSONDecoder().decode([RLMLogChooseRow].self, from: data)

                        // Add default rows, et al.
                        RLMLogChooseRow.createOrUpdateAll(with: log)

                    } catch {
                        DDLogError("JSON Decoding error = \(error)")
                        fatalError("JSON Decoding error = \(error)")
                    }
                }

                self?.showActivityIndicator(withStatus: "Syncing ...")
                syncEngine.syncAll { error in
                    syncEngine.print_isSyncingStatus_description()
                    if let error = error {
                        completion(error)
                    } else {
                        self?.hideActivityIndicator()
                        completion(nil)
                    }
                }

            case .failure(let error):
                completion(error)
            }
        }
    }

    private func onSignInLaunchCheck() {
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

    // MARK: - Sign Out

    func signOut(completion:@escaping (AppError?) -> Void) {
        showActivityIndicator(withStatus: "Signing Out...")
        UserAPIService.logout { [weak self] result in
            switch result {
            case .success(let message):
                DDLogVerbose("Logged out from the serve successfully.✅  [with status code = \(message)]")
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

    private func resetSyncEngine(completion:@escaping () -> Void) {
        syncEngine.stopSyncTimer()
        syncEngine.isSyncCancelled = true
        syncEngine.notifySyncStateChanged(message: "...cancelling...")

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
