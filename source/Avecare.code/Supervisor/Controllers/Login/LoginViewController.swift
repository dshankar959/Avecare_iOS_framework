import Foundation
import UIKit
import CocoaLumberjack



class LoginViewController: UIViewController, IndicatorProtocol {

    var keyBoardHidden = false
    let keyboardOffset: CGFloat = 150.0
    @IBOutlet var loginField: UITextField?
    @IBOutlet var passwordField: UITextField?


    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.keyboardDidChangeFrame(notification:)),
                                               name: UIResponder.keyboardDidChangeFrameNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LoginViewController.keyboardWillHide(notification:)),
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

//        loginField?.text = "room100_littlemonkey@gmail.com"    // Devika
//        passwordField?.text = "Spiria123"

//        loginField?.text = "room_crybabies@avecare.com"
//        passwordField?.text = "crybaby123"

//        loginField?.text = "roomg3@spiria.com"
//        passwordField?.text = "hnpura69"

//        loginField?.text = "room_test@spiria.com"
//        passwordField?.text = "Test123t"

        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        #if !DEBUG
            loginField?.text = appSettings.lastUsername
            passwordField?.text = ""
        #endif
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        updateViewForKeyboard(notification: notification)
        keyBoardHidden = false
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        keyBoardHidden = true
    }

    @objc func keyboardDidChangeFrame(notification: NSNotification) {
        if !keyBoardHidden {
            updateViewForKeyboard(notification: notification)
        }
    }

    func updateViewForKeyboard(notification: NSNotification) {

        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
            self.view.frame.origin.y = 0
           return
        }
        if keyboardSize.size.height < keyboardOffset {
            self.view.frame.origin.y = 0 - keyboardSize.size.height
        } else {
            self.view.frame.origin.y = 0 - keyboardOffset
        }
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
                self?.showActivityIndicator(withStatus: NSLocalizedString("authenticate_syncing", comment: ""))
                syncEngine.syncAll { error in
                    syncEngine.print_isSyncingStatus_description()
                    if let error = error {
                        self?.handleError(error)
                    } else {
                        self?.hideActivityIndicator()
                        self?.performSegue(withIdentifier: R.segue.loginViewController.tabbar, sender: nil)
                    }
                }
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
