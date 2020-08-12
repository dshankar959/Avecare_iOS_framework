import UIKit
import CocoaLumberjack
import SnapKit



class AboutTableViewController: UITableViewController, IndicatorProtocol {

    let dataProvider = AboutDataProvider()
    let appInfoView = AppInfoView(frame: CGRect.zero)


    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("profile_about_title", comment: "")

        tableView.register(nibModels: [AboutTableViewCellModel.self])

        self.view.setSubviewForAutoLayout(appInfoView)

        tableView.tableFooterView = UIView() // remove bottom margin of the last cell
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if let tbc = tabBarController {
            appInfoView.snp.remakeConstraints { (make) in
                make.width.equalTo(tbc.tabBar.frame.size.width)
                make.height.equalTo(tbc.tabBar.frame.size.height*1.5)
                make.bottom.equalTo(tbc.tabBar.snp_topMargin)
            }
        }
    }

}


// MARK: -
extension AboutTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows(for: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        let cell = tableView.dequeueReusableCell(withAnyModel: model, for: indexPath)

        if indexPath.section == AboutSections.support.rawValue, let cell = cell as? AboutTableViewCell {
            cell.accessoryViewLabel.text = ""
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == AboutSections.about.rawValue {
            let details = AboutDetails.allCases[indexPath.row]
            performSegue(withIdentifier: R.segue.aboutTableViewController.details, sender: details)
        } else {
            sendFeedbackLogs()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9725490196, alpha: 1)

        let titleLabel: UILabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = titleLabel.textColor.withAlphaComponent(0.60)

        headerView.setSubviewForAutoLayout(titleLabel)

        titleLabel.snp.remakeConstraints { (make) -> Void in
            make.width.height.equalToSuperview()
            make.left.equalTo(25)   // to match Storyboard offset
        }

        switch section {
        case AboutSections.support.rawValue:
            titleLabel.text = "Support"
        default:
            titleLabel.text = ""
        }

        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case AboutSections.support.rawValue:
            return navigationController?.navigationBar.frame.size.height ?? 44
        default:
            return 10
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return navigationController?.navigationBar.frame.size.height ?? 44
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9725490196, alpha: 1)
        return footerView
    }

}


// MARK: - Navigation
extension AboutTableViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.aboutTableViewController.details.identifier,
            let details = R.segue.aboutTableViewController.details(segue: segue) {
            details.destination.aboutDetails = sender as! AboutDetails
        }
    }


    func sendFeedbackLogs() {
        showActivityIndicator(withStatus: "Sending feedback package.")

        UserAPIService.submitUserFeedback(for: appSession,
                                          comments: "User submitted feedback.  ⭐",
                                          withLogfiles: true) { [weak self] error in
            if let error = error {
                DDLogError("submitUserFeedback error = \(error)")
                self?.showErrorAlert(error)
            } else {
                self?.showSuccessIndicator(withStatus: "Success! 👍")
            }
        }
    }


    func navigateToUserFeedback() {
    }

}


// MARK: -
private enum AboutSections: Int, CaseIterable {
    case about = 0
    case support = 1
}

class AboutDataProvider {

    private struct Section {
        let menus: [AboutTableViewCellModel]
    }

    private lazy var dataSource: [Section] = [
        Section(menus: [    // about
            AboutTableViewCellModel(menuTitle: NSLocalizedString(AboutDetails.termsAndConditions.rawValue, comment: "")),
            AboutTableViewCellModel(menuTitle: NSLocalizedString(AboutDetails.privacyPolicy.rawValue, comment: ""))
        ]),
        Section(menus: [    // support
            AboutTableViewCellModel(menuTitle: NSLocalizedString("Send feedback logs", comment: "feedback"))
        ])
    ]

    var numberOfSections: Int {
        return AboutSections.allCases.count
    }

    func numberOfRows(for section: Int) -> Int {
        return dataSource[section].menus.count
    }

    func model(for indexPath: IndexPath) -> AboutTableViewCellModel {
        return dataSource[indexPath.section].menus[indexPath.row]
    }


}
