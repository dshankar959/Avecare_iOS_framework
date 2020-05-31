import UIKit
import CocoaLumberjack



protocol SubjectSelectionProtocol: class {
    var subject: RLMSubject? { get set }
}


class GuardianTabBarController: UITabBarController, SubjectSelectionProtocol {
    // shared subject selection
    var subject: RLMSubject?
    var loginFlowNavigation: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("")
    }

    func onLogout() {
        if let loginFlowNavigation = loginFlowNavigation {
            loginFlowNavigation.popToRootViewController(animated: false)
        }
        dismiss(animated: true, completion: nil)
    }
}
