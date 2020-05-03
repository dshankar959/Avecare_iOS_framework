import Foundation
import UIKit

class SplashViewController: UIViewController {
    var sessionService: ValidateSessionProtocol! = ValidateSessionMockService()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        sessionService.isSessionValid({ (isValid) in
            if isValid {
                self.performSegue(withIdentifier: R.segue.splashViewController.tabbar, sender: nil)
            } else {
                self.performSegue(withIdentifier: R.segue.splashViewController.login, sender: nil)
            }
        })

    }
}
