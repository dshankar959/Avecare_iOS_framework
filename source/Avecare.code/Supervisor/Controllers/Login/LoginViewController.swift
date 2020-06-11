import Foundation
import UIKit
import CocoaLumberjack



class LoginViewController: UIViewController, IndicatorProtocol {

    let keyboardOffset: CGFloat = 190.0
    @IBOutlet var loginField: UITextField?
    @IBOutlet var passwordField: UITextField?


    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        #if DEBUG

//        loginField?.text = "535cc_Room_100@avecare.com" // School Age
//        loginField?.text = "535cc_Room_200@avecare.com" // Preschool
//        loginField?.text = "535cc_Room_300@avecare.com" // Toddler
//        loginField?.text = "535cc_Room_400@avecare.com" // Kindergarten

//        loginField?.text = "supervisor@example.net"
        loginField?.text = "room_13@avecare.com"    // quarantine

        passwordField?.text = "123456"

//        loginField?.text = " dshankar@spiria.com"
//        passwordField?.text = "hnpura69"

        #endif

    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
        if keyboardSize.size.height < keyboardOffset {
            self.view.frame.origin.y = 0 - keyboardSize.size.height
        } else {
            self.view.frame.origin.y = 0 - keyboardOffset
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
      self.view.frame.origin.y = 0
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
