import UIKit

class StoriesListViewController: UIViewController {

    @IBOutlet weak var subjectFilterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    let dataProvider: StoriesDataProvider = DefaultStoriesDataProvider()
    lazy var slideInTransitionDelegate = SlideInPresentationManager()

    weak var subjectSelection: SubjectSelectionProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        subjectSelection = tabBarController as? GuardianTabBarController

        tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        tableView.register(nibModels: [
            StoriesTableViewCellModel.self,
            SupervisorFilterTableViewCellModel.self
        ])

        self.navigationController?.hideHairline()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateScreen()
    }

    @IBAction func subjectFilterButtonTouched(_ sender: UIButton) {
        performSegue(withIdentifier: R.segue.storiesListViewController.subjectList.identifier, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.storiesListViewController.details.identifier,
            let details = R.segue.storiesListViewController.details(segue: segue) {
            details.destination.details = sender as? StoriesDetails
        }

        if segue.identifier == R.segue.storiesListViewController.subjectList.identifier,
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

        if segue.identifier == R.segue.storiesListViewController.educatorDetails.identifier,
            let destination = segue.destination as? EducatorDetailsViewController {
            destination.selectedEducatorId = sender as? String ?? ""
            destination.direction = .bottom
            slideInTransitionDelegate.direction = .bottom
            slideInTransitionDelegate.sizeOfPresentingViewController = .zero
            destination.transitioningDelegate = slideInTransitionDelegate
            destination.modalPresentationStyle = .custom
        }
    }

    private func updateScreen() {
        updateSubjectFilterButton()
        updateEducators()
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

    private func updateEducators() {
        if let selectedSubject = subjectSelection?.subject {
            dataProvider.unitIds = Array(selectedSubject.unitIds)
        } else {
            dataProvider.unitIds = [String]()
        }
        tableView.reloadData()
    }
}

extension StoriesListViewController: SubjectListViewControllerDelegate {
    func subjectListDidSelectAll(_ controller: SubjectListViewController) {
        controller.dismiss(animated: true)
        subjectSelection?.subject = nil
        updateScreen()
    }

    func subjectList(_ controller: SubjectListViewController, didSelect subject: RLMSubject) {
        controller.dismiss(animated: true)
        subjectSelection?.subject = subject
        updateScreen()
    }
}

extension StoriesListViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows(for: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        let cell = tableView.dequeueReusableCell(withAnyModel: model, for: indexPath)

        cell.separatorInset = .zero
        cell.layoutMargins = .zero

        if let supervisorCell = cell as? SupervisorFilterTableViewCell {
            supervisorCell.refreshView()
            supervisorCell.parentVC = self
        }

        return cell
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }

        let details = dataProvider.details(at: indexPath)
        performSegue(withIdentifier: R.segue.storiesListViewController.details, sender: details)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return .leastNormalMagnitude
        default:
            return 8
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

extension StoriesListViewController: ViewControllerWithSupervisorFilterViewCell {
    func educatorDidSelect(selectedEducatorId: String) {
        performSegue(withIdentifier: R.segue.storiesListViewController.educatorDetails, sender: selectedEducatorId)
    }
}
