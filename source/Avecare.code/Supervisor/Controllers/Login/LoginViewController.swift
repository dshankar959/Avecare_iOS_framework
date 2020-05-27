import Foundation
import UIKit
import CocoaLumberjack



class LoginViewController: UIViewController, IndicatorProtocol {

    @IBOutlet var loginField: UITextField?
    @IBOutlet var passwordField: UITextField?


    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
//        loginField?.text = "supervisor@example.net"
//        passwordField?.text = "123456"

//        loginField?.text = "535cc_Room_100@avecare.com" // School Age
//        loginField?.text = "535cc_Room_200@avecare.com" // Preschool
//        loginField?.text = "535cc_Room_300@avecare.com" // Toddler
//        loginField?.text = "535cc_Room_400@avecare.com" // Kindergarten
        loginField?.text = "room_13@avecare.com"    // quarantine
        passwordField?.text = "123456"
        #endif

    }


    @IBAction func signInAction(sender: UIButton) {
        guard let email = loginField?.text, let password = passwordField?.text else {
            self.showErrorAlert(AuthError.emptyCredentials.message)
            return
        }

        let userCredentials = UserCredentials(email: email, password: password)
        UserAuthenticateService.shared.signIn(userCredentials: userCredentials) { [weak self] error in
            if let error = error {
                self?.handleError(error)
            } else {
                self?.performSegue(withIdentifier: R.segue.loginViewController.tabbar, sender: nil)
            }
        }
    }


    private func handleError(_ error: AppError) {
        DDLogError("\(error)")
        self.showErrorAlert(error)
    }


    deinit {
        DDLogWarn("\(self)")
    }

}
