import UIKit
import CocoaLumberjack



class HomeViewController: UIViewController, IndicatorProtocol, PullToRefreshProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subjectFilterButton: UIButton!

    let dataProvider: HomeDataProvider = DefaultHomeDataProvider()
    lazy var slideInTransitionDelegate = SlideInPresentationManager()

    weak var subjectSelection: SubjectSelectionProtocol?

    var pullToRefreshHeaderView: PullToRefreshHeaderView!

    private let noItemCellIdntifier = "noItemCell"
    private var isRefreshing = true // Prevent to show no item cell when screen is loaded


    override func viewDidLoad() {
        super.viewDidLoad()

        if let tabBarController = tabBarController as? GuardianTabBarController {
            subjectSelection = tabBarController
            tabBarController.homeViewController = self
        }

        tableView.register(nibModels: [
            LogsNoteTableViewCellModel.self,
            HomeTableViewDisclosureCellModel.self
        ])

        self.navigationController?.hideHairline()
        tableView.tableFooterView = UIView() // remove bottom margin of the last cell
        tableView.register(UINib(nibName: "NoItemTableViewCell", bundle: nil), forCellReuseIdentifier: noItemCellIdntifier)

        setupPullToRefresh(for: self.tableView) { [weak self] in
            self?.isRefreshing = true
            self?.tableView.reloadData()
            // Retrieve data
            self?.refreshData { error in
                if let uiTableView = self?.tableView {
                    self?.endPullToRefresh(for: uiTableView)
                }
                if let error = error {
                    self?.showErrorAlert(error)
                }
                self?.isRefreshing = false
                self?.updateScreen()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: {  // let the animations settle delay.
            DDLogInfo("ℹ️ sync/refresh")
            self.triggerPullToRefresh(for: self.tableView)
        })

        NotificationCenter.default.addObserver(self, selector: #selector(navigateDeepLink), name: .didReceivePushNotification, object: nil)

        // TODO:  push notifications.
//        appDelegate.requestAuthorizationForPushNotifications()
    }


    @objc func navigateDeepLink(notification: NSNotification) {
        DDLogVerbose("‼️")

        if let info = notification.userInfo as? [String: Any] {

            if let navC = tabBarController?.viewControllers?[TabBarItems.home.index] as? UINavigationController {
                if navC.viewControllers.count > 1 {
                    navC.popToRootViewController(animated: false)
                }
                self.tabBarController?.selectedIndex = TabBarItems.home.index
            }
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Update selected subject id
        if dataProvider.selectedSubjectId != subjectSelection?.subject?.id {
            dataProvider.selectedSubjectId = subjectSelection?.subject?.id
        }

        // Update screen in case feeds are updated from stories screen
        if !isRefreshing { // Update screen only when data is not refreshing
            updateScreen()
        }
    }


    func refreshData(completion: @escaping (AppError?) -> Void) {
        // sync syncengine, then fetch feeds
        syncEngine.syncAll { error in
            syncEngine.print_isSyncingStatus_description()
            if let error = error {
                completion(error)
            } else {
                self.dataProvider.fetchFeeds { error in
                    completion(error)
                }
            }
        }
    }


    private func updateScreen() {
        updateSubjectFilterButton()
        tableView.reloadData()
    }


    private func updateSubjectFilterButton() {
        let titleText: String
        if let selectedSubject = subjectSelection?.subject {
            titleText =  "\(selectedSubject.firstName) \(selectedSubject.lastName)"
        } else {
            titleText = NSLocalizedString("subjectlist_all", comment: "").capitalized
        }
        let titleFont = UIFont.systemFont(ofSize: 16)
        let titleAttributedString = NSMutableAttributedString(string: titleText + "  ", attributes: [NSAttributedString.Key.font: titleFont])

        let chevronFont = UIFont(name: "FontAwesome5Pro-Light", size: 12)
        let chevronAttributedString = NSAttributedString(string: "\u{f078}", attributes: [NSAttributedString.Key.font: chevronFont!])
        titleAttributedString.append(chevronAttributedString)

        subjectFilterButton.setAttributedTitle(titleAttributedString, for: .normal)
    }
}


extension HomeViewController: SubjectListViewControllerDelegate {

    func subjectListDidSelectAll(_ controller: SubjectListViewController) {
        controller.dismiss(animated: true)
        subjectSelection?.subject = nil
        dataProvider.selectedSubjectId = nil
        updateScreen()
    }

    func subjectList(_ controller: SubjectListViewController, didSelect subject: RLMSubject) {
        controller.dismiss(animated: true)
        subjectSelection?.subject = subject
        dataProvider.selectedSubjectId = subject.id
        updateScreen()
    }
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfSections = dataProvider.numberOfSections
        if numberOfSections > 0 || isRefreshing {
            return numberOfSections
        } else {
            return 1
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfSections = dataProvider.numberOfSections
        if numberOfSections > 0 || isRefreshing {
            return dataProvider.numberOfRows(section: section)
        } else {
            return 1
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let numberOfSections = dataProvider.numberOfSections
        if numberOfSections > 0 || isRefreshing {
            let model = dataProvider.model(for: indexPath)
            let cell = tableView.dequeueReusableCell(withAnyModel: model, for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: noItemCellIdntifier,
                                                     for: indexPath)
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dataProvider.headerViewModel(for: section)?.buildView()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let model = dataProvider.model(for: indexPath) as? HomeTableViewDisclosureCellModel {
            gotoDetailsScreen(with: model)
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if dataProvider.hasImportantItems, indexPath.section == 0 {
            return true // only important item can be removed
        } else {
            return false
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataProvider.removeData(at: indexPath)
            tableView.reloadData()
        }
    }

}
