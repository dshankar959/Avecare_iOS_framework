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
        noItemTitleLabel.text = "Welcome!"
        // swiftlint:disable line_length
        noItemContentLabel.text = "This is your Home screen; items will be added by your child's educator as well as by their centre's administration.\n\nPeriodically information will be added to this screen - stay tuned!"
        // swiftlint:enable line_length
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showActivityIndicator(withStatus: "Retrieving Feeds...")
        dataProvider.fetchFeed { error in
            self.hideActivityIndicator()
            if let error = error {
                self.showErrorAlert(error)
            }
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
            titleText = "All"
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
