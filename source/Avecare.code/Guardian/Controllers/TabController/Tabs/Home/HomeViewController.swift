import UIKit
import CocoaLumberjack



class HomeViewController: UIViewController, IndicatorProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subjectFilterButton: UIButton!
    @IBOutlet weak var noItemView: UIView!
    @IBOutlet weak var noItemTitleLabel: UILabel!
    @IBOutlet weak var noItemContentLabel: UILabel!

    let dataProvider: HomeDataProvider = DefaultHomeDataProvider()
    lazy var slideInTransitionDelegate = SlideInPresentationManager()

    weak var subjectSelection: SubjectSelectionProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        subjectSelection = tabBarController as? GuardianTabBarController

        tableView.register(nibModels: [
            LogsNoteTableViewCellModel.self,
            HomeTableViewDisclosureCellModel.self
        ])

        self.navigationController?.hideHairline()
        configNoItemView()
        tableView.tableFooterView = UIView() // remove bottom margin of the last cell
    }

    private func configNoItemView() {
        noItemTitleLabel.text = NSLocalizedString("home_no_item_title", comment: "")
        noItemContentLabel.text = NSLocalizedString("home_no_item_content", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showActivityIndicator(withStatus: NSLocalizedString("home_retrieving_feed", comment: ""))
        dataProvider.fetchFeeds { error in
            self.hideActivityIndicator()
            if let error = error {
                self.showErrorAlert(error)
            }
            self.dataProvider.filterDataSource(with: self.subjectSelection?.subject?.id)
            self.updateScreen()
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
            let tuple = sender as? (FeedItemType, String)
            destination.feedItemType = tuple?.0
            destination.feedItemId = tuple?.1
        }
    }

    private func updateScreen() {
        noItemView.isHidden = dataProvider.numberOfSections > 0 ? true : false
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
        dataProvider.filterDataSource(with: nil)
        updateScreen()
    }

    func subjectList(_ controller: SubjectListViewController, didSelect subject: RLMSubject) {
        controller.dismiss(animated: true)
        subjectSelection?.subject = subject
        dataProvider.filterDataSource(with: subject.id)
        updateScreen()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.numberOfSections
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows(section: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        let cell = tableView.dequeueReusableCell(withAnyModel: model, for: indexPath)
        return cell
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

    private func gotoDetailsScreen(with model: HomeTableViewDisclosureCellModel) {
        switch model.feedItemType {
        case .subjectDailyLog:
            gotoLogsScreen(with: model.feedItemId)
        case .message:
            performSegue(withIdentifier: R.segue.homeViewController.details, sender: (model.feedItemType, model.feedItemId))
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

    // TODO: review technical design on how we should handle dismissing notifications [S.D]
/*
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard dataProvider.canDismiss(at: indexPath) else { return nil }
        let action = UIContextualAction(style: .destructive, title: "Dismiss") { _, _, closure in
            DDLogVerbose("Dismiss")
            closure(true)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
*/
}
