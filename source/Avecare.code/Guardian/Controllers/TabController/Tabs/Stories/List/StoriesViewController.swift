import UIKit



class StoriesListViewController: UIViewController {

    @IBOutlet weak var subjectFilterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var dataProvider: StoriesDataProvider = DefaultStoriesDataProvider()
    lazy var slideInTransitionDelegate = SlideInPresentationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
        tableView.register(nibModels: [
            StoriesTableViewCellModel.self,
            SupervisorFilterTableViewCellModel.self
        ])

        setSubjectFilerButtonTitle(titleText: "All")

        self.navigationController?.hideHairline()
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
            destination.allSubjectsIncluded = true
            slideInTransitionDelegate.direction = .bottom
            slideInTransitionDelegate.sizeOfPresentingViewController = CGSize(width: view.frame.size.width,
                                                                              height: destination.contentHeight)
            destination.transitioningDelegate = slideInTransitionDelegate
            destination.modalPresentationStyle = .custom
        }
    }

    private func setSubjectFilerButtonTitle(titleText: String) {
        let titleFont = UIFont.systemFont(ofSize: 16)
        let titleAttributedString = NSMutableAttributedString(string: titleText + "  ", attributes: [NSAttributedString.Key.font: titleFont])
        let chevronFont = UIFont(name: "FontAwesome5Pro-Light", size: 12)
        let chevronAttributedString = NSAttributedString(string: "\u{f078}", attributes: [NSAttributedString.Key.font: chevronFont!])
        titleAttributedString.append(chevronAttributedString)

        subjectFilterButton.setAttributedTitle(titleAttributedString, for: .normal)
    }
}

extension StoriesListViewController: SubjectListViewControllerDelegate {
    func subjectList(_ controller: SubjectListViewController, didSelect item: SubjectListTableViewCellModel) {
        controller.dismiss(animated: true)
        setSubjectFilerButtonTitle(titleText: item.title)
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
