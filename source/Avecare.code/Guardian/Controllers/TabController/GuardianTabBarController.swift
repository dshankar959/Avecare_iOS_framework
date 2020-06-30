import UIKit
import CocoaLumberjack



private enum TabBarItems: String, CaseIterable {
    case home = "Home"
    case stories = "Documentation"
    case logs = "Logs"
    case profile = "Profile"
}


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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureTabBar()
    }


    private func configureTabBar() {
        if let tabBarItems = tabBar.items {
            for (index, item) in tabBarItems.enumerated() {
                item.title = TabBarItems.allCases[index].rawValue
            }
        }
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
