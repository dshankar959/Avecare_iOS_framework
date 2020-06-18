import UIKit
import CocoaLumberjack
import SegueManager


class LoginViewController: UIViewController, SeguePerformer, IndicatorProtocol {

    @IBOutlet weak var snowflakeIconLabel: UILabel!
    @IBOutlet weak var snowflakeTitleLabel: UILabel!
    @IBOutlet var loginField: UITextField?

    lazy var segueManager: SegueManager = {
        // SegueManager based on the current view controller
        return SegueManager(viewController: self)
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        snowflakeIconLabel.font = UIFont(name: "FontAwesome5Pro-Light", size: 24)
        snowflakeIconLabel.text = "\u{f2dc}"
        snowflakeTitleLabel.text = "Daily Wonders"
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #if DEBUG
//        loginField?.text = "sdwornik@spiria.com"
        loginField?.text = "guardian@example.net"
//        loginField?.text = "shankardevika@yahoo.ca"
//        loginField?.text = "dshankar@spiria.com"

//        loginField?.text = "parent1@example.net"
//        loginField?.text = "parent2@example.net"
//        loginField?.text = "parent3@example.net"
//        loginField?.text = "parent4@example.net"

        // auto-sign-in, to speed up local testing.
        getCodeAction(sender: UIButton())

        #endif
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }


    @IBAction func getCodeAction(sender: UIButton) {
        guard let email = loginField?.text else {
            self.showErrorAlert(AuthError.emptyCredentials.message)
            return
        }

        showActivityIndicator(withStatus: NSLocalizedString("requst_onetime_password", comment: ""))

        // otp
        UserAPIService.requestOTP(email: email) { [weak self] result in
            self?.hideActivityIndicator()

            switch result {
            case .success(let message):
                DDLogVerbose("Successful request of OTP.  👍  [withMessage = \(message)]")

                self?.performSegue(withIdentifier: R.segue.loginViewController.otp.identifier) { segue in
                    guard let otpVC = segue.destination as? OTPViewController else {
                        DDLogError("otpVC error")
                        fatalError("otpVC error")
                    }
                    otpVC.email = email
                }
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segueManager.prepare(for: segue)
    }


    private func handleError(_ error: AppError) {
        DDLogError("\(error)")
        self.showErrorAlert(error)
    }

}
