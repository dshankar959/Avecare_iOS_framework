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
        snowflakeTitleLabel.text = "Daily Wonders"  // TODO: app name should be taken from theme package

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
        UserAuthenticateService.shared.signIn(userCredentials: userCredentials) { [weak self] error in
            if let error = error {
                self?.handleError(error)
            } else {
                self?.performSegue(withIdentifier: R.segue.otpViewController.tabbar, sender: nil)
            }
        }
    }

    private func handleError(_ error: AppError) {
        DDLogError("\(error)")
        self.showErrorAlert(error)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.otpViewController.tabbar.identifier,
            let destination = segue.destination as? GuardianTabBarController {
            destination.loginFlowNavigation = navigationController
        }
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
