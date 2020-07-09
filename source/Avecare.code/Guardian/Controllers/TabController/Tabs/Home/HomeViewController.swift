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
        tableView.register(UINib(nibName: "NoItemTableViewCell", bundle: nil),
                           forCellReuseIdentifier: noItemCellIdntifier)

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


    @IBAction func didClickSubjectPickerButton(_ sender: UIButton) {
        performSegue(withIdentifier: R.segue.homeViewController.subjectList.identifier, sender: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.homeViewController.subjectList.identifier,
           let destination = segue.destination as? SubjectListViewController {
            destination.delegate = self
            destination.dataProvider.allSubjectsIncluded = true
            destination.direction = .bottom
            slideInTransitionDelegate.direction = .bottom
            slideInTransitionDelegate.sizeOfPresentingViewController = CGSize(width: view.frame.size.width,
                                                                              height: destination.contentHeight)
            destination.transitioningDelegate = slideInTransitionDelegate
            destination.modalPresentationStyle = .custom
        } else if segue.identifier == R.segue.homeViewController.details.identifier,
            let destination = segue.destination as? FeedDetailsViewController {
            let tuple = sender as? (String, FeedItemType, String)
            destination.feedTitle = tuple?.0
            destination.feedItemType = tuple?.1
            destination.feedItemId = tuple?.2
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

    private func gotoDetailsScreen(with model: HomeTableViewDisclosureCellModel) {
        switch model.feed.feedItemType {
        case .subjectDailyLog:
            gotoLogsScreen(with: model.feed.feedItemId)
        case .message, .unitActivity, .subjectInjury, .subjectReminder:
            performSegue(withIdentifier: R.segue.homeViewController.details, sender: (model.title, model.feed.feedItemType, model.feed.feedItemId))
        case .unitStory:
            gotoStoryDetailScreen(with: model.feed.feedItemId)
        default:
            return
        }
    }

    private func gotoLogsScreen(with feedItemId: String) {
        if let navC = tabBarController?.viewControllers?[2] as? UINavigationController {
            if navC.viewControllers.count > 1 {
                navC.popToRootViewController(animated: false)
            }
            if let logsVC = navC.viewControllers.first as? LogsViewController {
                logsVC.selectedLogId = feedItemId
            }
        }

        // Animated transition
        guard let fromView = tabBarController?.selectedViewController?.view,
            let toView = tabBarController?.viewControllers?[2].view else { return }

        fromView.superview?.addSubview(toView)
        let screenWidth = UIScreen.main.bounds.width
        toView.center = CGPoint(x: fromView.center.x + screenWidth, y: fromView.center.y)

        view.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.3, animations: {
            fromView.center = CGPoint(x: fromView.center.x - screenWidth, y: fromView.center.y)
            toView.center = CGPoint(x: toView.center.x - screenWidth, y: toView.center.y)
        }) { finished in
            if finished {
                fromView.removeFromSuperview()
                toView.removeFromSuperview()
                self.tabBarController?.selectedIndex = 2
                self.view.isUserInteractionEnabled = true
            }
        }
    }

    private func gotoStoryDetailScreen(with feedItemId: String) {
        if let story = RLMStory.find(withID: feedItemId),
            let detailsVC = UIStoryboard(name: R.storyboard.stories.name, bundle: .main)
                .instantiateViewController(withIdentifier: "StoriesDetailsViewController") as? StoriesDetailsViewController {
            detailsVC.details = StoriesDetails(title: story.title, pdfURL: story.pdfURL(using: DocumentService()), date: story.serverLastUpdated)
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }

}
