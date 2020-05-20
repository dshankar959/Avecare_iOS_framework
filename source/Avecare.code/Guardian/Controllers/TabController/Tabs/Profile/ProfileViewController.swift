//
//  ProfileViewController.swift
//  guardian
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileTableView: UITableView!

    let dataProvider: ProfileDataProvider = DefaultProfileDataProvider()
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
                subjectSelection?.subject = subject
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
        /*
        (cell as? ProfileSubjectTableViewCell)?.refreshView()
        (cell as? ProfileSubjectTableViewCell)?.parentVC = self*/
        (cell as? SupervisorFilterTableViewCell)?.refreshView()

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
