import Foundation
import UIKit
import CocoaLumberjack
import SegueManager



class LoginViewController: UIViewController, SeguePerformer, IndicatorProtocol {
    @IBOutlet var loginField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
//        #if DEBUG
            loginField?.text = "guardian@example.net"
//        #endif
    }

    @IBAction func getCodeAction(sender: UIButton) {
        guard let email = loginField?.text else {
            return
        }
        // otp
        UserAPIService.requestOTP(email: email) { [weak self] result in
            self?.hideActivityIndicator()
            switch result {
            case .success(let message):
                DDLogVerbose("Successful request OTP.  👍  [withMessage = \(message)]")

                self?.performSegue(withIdentifier: R.segue.loginViewController.otp.identifier) { segue in
                    guard let otpVC = segue.destination as? OTPViewController else {
                        fatalError()
                    }
                    otpVC.email = email
                }
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    lazy var segueManager: SegueManager = {
      // SegueManager based on the current view controller
      return SegueManager(viewController: self)
    }()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      segueManager.prepare(for: segue)
    }
    private func handleError(_ error: AppError) {
        DDLogError("\(error)")
        self.showErrorAlert(error)
    }
}
