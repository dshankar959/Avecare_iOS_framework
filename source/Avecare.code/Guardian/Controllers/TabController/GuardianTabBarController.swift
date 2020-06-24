import UIKit
import CocoaLumberjack



protocol SubjectSelectionProtocol: class {
    var subject: RLMSubject? { get set }
}


class GuardianTabBarController: UITabBarController, SubjectSelectionProtocol {

    // shared subject selection
    var subject: RLMSubject?

    var loginFlowNavigation: UINavigationController?
    var homeViewController: HomeViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("")
    }

    func onLogout() {
        loginFlowNavigation?.popToRootViewController(animated: false)
        dismiss(animated: true, completion: nil)
    }

    func refreshData(completion: @escaping (AppError?) -> Void) {
        homeViewController?.refreshData(completion: { (error) in
            completion(error)
        })
    }
}
