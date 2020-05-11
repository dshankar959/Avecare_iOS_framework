import Foundation
import UIKit
import CocoaLumberjack
import FirebaseCrashlytics



class OTPViewController: UIViewController, IndicatorProtocol {

    @IBOutlet var otpField: PinView?

    var email: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        otpField?.style = .box
    }


    @IBAction func sendCodeAction(sender: UIButton) {
        guard let email = email, let otp = otpField?.getPin() else {
            self.showErrorAlert(AuthError.emptyCredentials.message)
            return
        }

        let userCredentials = UserCredentials(email: email, password: otp)
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
//                        RLMLogChooseRow().clean()   // wipe rows
                        let data = try Data(resource: R.file.logFormRowsJson)
                        let log = try JSONDecoder().decode([RLMLogChooseRow].self, from: data)

                        // Add default rows, et al.
                        RLMLogChooseRow().createOrUpdateAll(with: log)

                    } catch {
                        DDLogError("JSON Decoding error = \(error)")
                        fatalError("JSON Decoding error = \(error)")
                    }
                }

                self?.showActivityIndicator(withStatus: "Syncing data")
                syncEngine.syncAll { error in
                    syncEngine.print_isSyncingStatus_description()
                    if let error = error {
                        self?.handleError(error)
                    } else {
                        self?.hideActivityIndicator()
                        self?.performSegue(withIdentifier: R.segue.otpViewController.tabbar, sender: nil)
                    }
                }

            case .failure(let error):
                self?.handleError(error)
            }
        }
    }


    private func handleError(_ error: AppError) {
        DDLogError("\(error)")
        self.showErrorAlert(error)
    }


    func onSignInLaunchCheck() {
        DALConfig.userRealmFileURL = nil    // reset DB access.

        appSettings.userLoginCount += 1
        if appSettings.isFirstLogin() {
            /// First time, fresh install, new user, etc.  Set defaults.
            appSettings.rememberLastUsername = true
            appSettings.enableSyncUp = true
            appSettings.enableSyncDown = true
        }

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


    deinit {
        DDLogWarn("\(self)")
    }

}
