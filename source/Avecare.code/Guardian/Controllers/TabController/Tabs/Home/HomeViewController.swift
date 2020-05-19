import UIKit
import CocoaLumberjack



class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subjectFilterButton: UIButton!

    var dataProvider: HomeDataProvider = DefaultHomeDataProvider()
    lazy var slideInTransitionDelegate = SlideInPresentationManager()

    var selectedSubject: RLMSubject? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(nibModels: [
            LogsNoteTableViewCellModel.self,
            HomeTableViewDisclosureCellModel.self
        ])

        self.navigationController?.hideHairline()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateScreen()
    }

    @IBAction func didClickSubjectPickerButton(_ sender: UIButton) {
        performSegue(withIdentifier: R.segue.homeViewController.subjectList.identifier, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.homeViewController.subjectList.identifier,
           let destination = segue.destination as? SubjectListViewController {
            destination.delegate = self
            destination.listIncludesAllSelection = true
            slideInTransitionDelegate.direction = .bottom
            slideInTransitionDelegate.sizeOfPresentingViewController = CGSize(width: view.frame.size.width,
                                                                              height: destination.contentHeight)
            destination.transitioningDelegate = slideInTransitionDelegate
            destination.modalPresentationStyle = .custom
        }
    }

    private func updateScreen() {
        updateSelectedSubject()
        // TODO - update screen with selected subject
        updateSubjectFilerButton()
    }

    private func updateSelectedSubject() {
        if let selectedSubjectId = selectedSubjectId {
            selectedSubject = RLMSubject.find(withID: selectedSubjectId)
        } else {
            selectedSubject = nil
        }
    }

    private func updateSubjectFilerButton() {
        let titleText: String
        if let selectedSubject = selectedSubject {
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
    func subjectList(_ controller: SubjectListViewController, didSelect item: SubjectListTableViewCellModel) {
        controller.dismiss(animated: true)

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

    // TODO: review technical design on how we should handle dismissing notifications
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
