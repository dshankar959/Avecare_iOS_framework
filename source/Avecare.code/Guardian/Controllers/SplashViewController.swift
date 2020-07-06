import UIKit



class SplashViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if appSession.isSignedIn() {
            self.performSegue(withIdentifier: R.segue.splashViewController.tabbar, sender: nil)
        } else {
            self.performSegue(withIdentifier: R.segue.splashViewController.login, sender: nil)
        }
    }

}
