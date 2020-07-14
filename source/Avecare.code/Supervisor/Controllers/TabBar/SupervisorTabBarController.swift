import Foundation
import UIKit
import SnapKit
import FirebaseCrashlytics



private enum TabBarItems: String, CaseIterable {
    case logs = "Logs"
    case notifications = "Notifications"
    case stories = "Documentation"
    case settings = "Settings"
}


struct TabBarConfig {
    static let tabBarHeight: CGFloat = 80
}


class SupervisorTabBarController: UITabBarController {

    private lazy var customBar: CustomTabBarView = {
        return CustomTabBarView(delegate: self)
    }()

    var observation: NSKeyValueObservation?

    override var selectedIndex: Int {
        didSet {
            customBar.sync()
            selectedViewController?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: TabBarConfig.tabBarHeight, right: 0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        #if !DEBUG
            // #Crashlytics logging
            Crashlytics.crashlytics().setUserID(appSession.userProfile.email)
        #endif

        configureTabBar()
        syncEngine.resetSyncTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customBar.sync()
        selectedViewController?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: TabBarConfig.tabBarHeight, right: 0)
    }

    func onLogout() {
        dismiss(animated: true, completion: nil)
    }

    deinit {
        observation?.invalidate()
        observation = nil
    }

    private func configureTabBar() {
        if let tabBarItems = tabBar.items {
            for (index, item) in tabBarItems.enumerated() {
                item.title = TabBarItems.allCases[index].rawValue
            }
        }

        view.addSubview(customBar)
        tabBar.isHidden = true
        customBar.setItems(tabBar.items, animated: false)
        observation = observe(\.tabBar.items, options: .new) { [weak self] _, change in
            if let items = change.newValue {
                self?.customBar.setItems(items, animated: false)
            }
        }
    }

}


extension SupervisorTabBarController: CustomTabBarViewDelegate {

    func tabBar(_ tabBar: CustomTabBarView, didClickItem button: SupervisorTabBarButton) {
        guard let item = button.item, let index = self.tabBar.items?.firstIndex(of: item),
            selectedIndex != index else {
                return
        }
        selectedIndex = index
    }

    var selectedTabBarItem: UITabBarItem? {
        return tabBar.selectedItem
    }

}
