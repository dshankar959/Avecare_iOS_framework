import UIKit
import SnapKit



class AboutTableViewController: UITableViewController {

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
        return dataProvider.numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        let cell = tableView.dequeueReusableCell(withAnyModel: model, for: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let details = AboutDetails.allCases[indexPath.row]
        performSegue(withIdentifier: R.segue.aboutTableViewController.details, sender: details)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9725490196, alpha: 1)
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
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

}


// MARK: -
private enum AboutSection: Int, CaseIterable {
    case `default` = 0
}

class AboutDataProvider {

    private lazy var dataSource: [AboutTableViewCellModel] = [
        AboutTableViewCellModel(menuTitle: NSLocalizedString(AboutDetails.termsAndConditions.rawValue, comment: "")),
        AboutTableViewCellModel(menuTitle: NSLocalizedString(AboutDetails.privacyPolicy.rawValue, comment: ""))
    ]

    var numberOfSections: Int {
        return AboutSection.allCases.count
    }

    var numberOfRows: Int {
        return dataSource.count
    }

    func model(for indexPath: IndexPath) -> AboutTableViewCellModel {
        return dataSource[indexPath.row]
    }

}
