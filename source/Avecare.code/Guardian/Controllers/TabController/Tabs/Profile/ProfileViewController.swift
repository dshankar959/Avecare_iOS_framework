//
//  ProfileViewController.swift
//  guardian
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileTableView: UITableView!

    lazy var dataProvider: ProfileDataProvider = {
        return DefaultProfileDataProvider()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        profileTableView.register(nibModels: [
            ProfileSubjectTableViewCellModel.self,
            SupervisorFilterTableViewCellModel.self,
            ProfileMenuTableViewCellModel.self
        ])

        self.navigationController?.hideHairline()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
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
        //
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
