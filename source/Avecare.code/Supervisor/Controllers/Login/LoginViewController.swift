import Foundation
import UIKit
import CocoaLumberjack
import FirebaseCrashlytics



class LoginViewController: UIViewController, IndicatorProtocol {

    @IBOutlet var loginField: UITextField?
    @IBOutlet var passwordField: UITextField?


    override func viewDidLoad() {
        super.viewDidLoad()
//        #if DEBUG
            loginField?.text = "supervisor@example.net"
            passwordField?.text = "123456"
//        #endif
    }


    @IBAction func signInAction(sender: UIButton) {
        guard let email = loginField?.text, let password = passwordField?.text else {
            self.showErrorAlert(AuthError.emptyCredentials.message)
            return
        }

        let userCredentials = UserCredentials(email: email, password: password)
        showActivityIndicator(withStatus: "Signing in ...")

        // auth -> account info -> supervisor details -> unit details -> tabbar
        UserAPIService.authenticateUserWith(userCreds: userCredentials) { [weak self] result in
            self?.hideActivityIndicator()

            switch result {
            case .success(let token):
                DDLogVerbose("Successful login.  👍  [withToken = \(token)]")
                let userProfile = UserProfile(userCredentials: userCredentials)

                // Update any previous session, with new token.
                appDelegate._session = Session(token: token, userProfile: userProfile)

                self?.onSignInLaunchCheck()

                RLMAccountInfo.saveAccountInfo(for: token.accountType, with: token.accountTypeId)

                #if !DEBUG
                    // #Crashlytics logging
                    Crashlytics.crashlytics().setUserID(userProfile.email)
                #endif

/*
                /// <- #Testing.
                /// reset DB with some defaults.
                do {
                    RLMLogChooseRow().clean()   // wipe rows

                    let data = try Data(resource: R.file.logFormRowsJson)
                    let decoder = JSONDecoder()r
                    let log = try decoder.decode([RLMLogChooseRow].self, from: data)

                    // Add default rows, et al.
//                    RLMLogChooseRow().createOrUpdateAll(with: log)

                    print(log.description)
                } catch {
                    print(error)
                }
                /// #Testing ->
*/

                self?.showActivityIndicator(withStatus: "Syncing data")
//                syncEngine.triggerSync()
                syncEngine.syncAll { error in
                    DDLogDebug("error = \(String(describing: error))")
//                    syncEngine.print_isSyncingStatus_description()
                    if let error = error {
                        self?.showErrorAlert(error)
                    } else if !syncEngine.isSyncing {
                    } else if syncEngine.isSyncCancelled {
                    }

                    self?.hideActivityIndicator()

                }


            case .failure(let error):
                self?.handleError(error)
            }
        }
    }



/*
    private func getSupervisorDetails(id: Int) {
        SupervisorsAPIService.getSupervisorDetails(for: id) { [weak self] result in
            switch result {
            case .success(let details):
                appDelegate._session.userProfile.details = details
                self?.getUnitDetails(id: details.primaryUnitId)
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }


    private func getUnitDetails(id: Int) {
        UnitAPIService.getUnitDetails(id: id) { [weak self] result in
            switch result {
            case .success(let details):
                appDelegate._session.unitDetails = details
                self?.getInstitutionDetails(id: details.institutionId)
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
*/

/*
    private func getListOfSubjects() {
        guard let unitId = appDelegate._session.unitDetails?.id else {
            return
        }
        UnitAPIService.getSubjects(id: unitId) { [weak self] result in
            switch result {
            case .success(let subjects):
                RLMSubject().createOrUpdateAll(with: subjects)
                self?.dataSource = RLMSubject().findAll()

                self?.sortBy(.firstName)
                self?.delegate?.didFetchDataSource()

            case .failure(let error):
                self?.delegate?.didFailure(error)
            }
        }
    }
*/


    private func getInstitutionDetails(id: Int) {
        InstitutionsAPIService.getInstitutionDetails(id: id) { [weak self] result in
            switch result {
            case .success(let details):
                appDelegate._session.institutionDetails = details
                self?.performSegue(withIdentifier: R.segue.loginViewController.tabbar, sender: nil)
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

        if appSettings.isFirstLaunch() {
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
