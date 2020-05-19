import Foundation
import UIKit
import CocoaLumberjack
import FirebaseCrashlytics



class OTPViewController: UIViewController, IndicatorProtocol, PinViewDelegate {

    @IBOutlet weak var snowflakeIconLabel: UILabel!
    @IBOutlet weak var snowflakeTitleLabel: UILabel!
    @IBOutlet var otpField: PinView?

    var email: String?


    override func viewDidLoad() {
        super.viewDidLoad()
        otpField?.style = .box
        otpField?.delegate = self

        snowflakeIconLabel.font = UIFont(name: "FontAwesome5Pro-Light", size: 24)
        snowflakeIconLabel.text = "\u{f2dc}"
        snowflakeTitleLabel.text = "Avecare"

        self.navigationController?.hideHairline()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let firstCell = otpField?.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? PinCell
        firstCell?.pinField.becomeFirstResponder()

        #if DEBUG
            // speed up local testing with auto-sign-in.
            otpField?.pastePin(pin: "1234")
            inputDidFinished()
        #endif
    }


    func inputDidFinished() {
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


        #if DEBUG
        if !appSettings.isFirstLogin() {
            // Control syncing.
            // If you've already synced down the data you want to work with, there is no need to keep syncing it down.
            // So you can disable syncing to speed-up coding.
            appSettings.enableSyncUp = false
            appSettings.enableSyncDown = false
        }
        #endif


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
        DDLogWarn("")
    }

}



extension OTPViewController {

    @IBAction func requestCodeAgain(_ sender: UIButton) {
        otpField?.clearPin()

        guard let email = email else {
            self.showErrorAlert(AuthError.emptyCredentials.message)
            return
        }
        showActivityIndicator(withStatus: "Requesting one-time password ...")

        // otp redo
        UserAPIService.requestOTP(email: email) { [weak self] result in
            self?.hideActivityIndicator()

            switch result {
            case .success(let message):
                DDLogVerbose("Successful re-request of OTP.  ✅  [withMessage = \(message)]")
                self?.showSuccessIndicator(withStatus: "New one-time password re-sent. 🔢")

                let firstCell = self?.otpField?.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? PinCell
                firstCell?.pinField.becomeFirstResponder()

            case .failure(let error):
                self?.handleError(error)
            }
        }
    }

}
