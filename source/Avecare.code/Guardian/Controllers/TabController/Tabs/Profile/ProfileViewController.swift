//
//  ProfileViewController.swift
//  guardian
//

import UIKit
import CocoaLumberjack

class ProfileViewController: UIViewController, IndicatorProtocol {

    @IBOutlet weak var profileTableView: UITableView!

    let dataProvider: ProfileDataProvider = DefaultProfileDataProvider()
    lazy var slideInTransitionDelegate = SlideInPresentationManager()
    weak var subjectSelection: SubjectSelectionProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        subjectSelection = tabBarController as? GuardianTabBarController
        (dataProvider as? DefaultProfileDataProvider)?.subjectSelection = subjectSelection

        profileTableView.register(nibModels: [
            ProfileSubjectTableViewCellModel.self,
            SupervisorFilterTableViewCellModel.self,
            ProfileMenuTableViewCellModel.self
        ])

        self.navigationController?.hideHairline()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateEducators()
    }

    func updateEducators() {
        // if subject not selected, select 1st by default
        if let selectedSubject = subjectSelection?.subject {
            dataProvider.unitIds = Array(selectedSubject.unitIds)
        } else {
            if dataProvider.subjectsProvider.numberOfRows > 0 {
                let indexPath = IndexPath(row: 0, section: 0)
                let subject = dataProvider.subjectsProvider.model(at: indexPath)
                //subjectSelection?.subject = subject -- Don't ever store it on subjectSelection
                dataProvider.unitIds = Array(subject.unitIds)
            } else {
                dataProvider.unitIds = [String]()
            }
        }

        profileTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.profileViewController.details.identifier,
            let details = R.segue.profileViewController.details(segue: segue) {
            details.destination.profileDetails = sender as! ProfileDetails
        }

        if segue.identifier == R.segue.profileViewController.educatorDetails.identifier,
            let destination = segue.destination as? EducatorDetailsViewController {
            destination.selectedEducator = sender as? EducatorSummaryTableViewCellModel

            slideInTransitionDelegate.direction = .bottom
            destination.transitioningDelegate = slideInTransitionDelegate
            destination.modalPresentationStyle = .custom
        }
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows(for: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        let cell = tableView.dequeueReusableCell(withAnyModel: model, for: indexPath)

        if let profileSubjectCell = cell as? ProfileSubjectTableViewCell {
            profileSubjectCell.parentVC = self
            profileSubjectCell.refreshView()
        }

        if let supervisorCell = cell as? SupervisorFilterTableViewCell {
            supervisorCell.refreshView()
            supervisorCell.parentVC = self
        }

        if indexPath.section < 2 {
            cell.selectionStyle = .none
        } else {
            cell.selectionStyle = .blue
        }

        if indexPath.section == 4 {
            cell.contentView.alpha = 0.54
        } else {
            cell.contentView.alpha = 1
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let details = ProfileDetails.menu//dataProvider.details(at: indexPath)
            performSegue(withIdentifier: R.segue.profileViewController.details, sender: details)
        } else if indexPath.section == 3 {
            performSegue(withIdentifier: R.segue.profileViewController.about, sender: nil)
        } else if indexPath.section == 4 {
            // Log out
            UserAthenticateService.shared.signOut { [weak self] error in
                if let error = error {
                    self?.showErrorAlert(error)
                } else {
                    if let tabBarController = self?.tabBarController as? GuardianTabBarController {
                        tabBarController.onLogout()
                    }
                }
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 3:
            return 1
        default:
            return .leastNormalMagnitude
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
}

extension ProfileViewController: ViewControllerWithSupervisorFilterViewCell {
    func educatorDidSelect(selectedEducatorSummary: EducatorSummaryTableViewCellModel) {
        performSegue(withIdentifier: R.segue.profileViewController.educatorDetails, sender: selectedEducatorSummary)
    }
}
