import UIKit



class AboutTableViewController: UITableViewController {

    let dataProvider = AboutDataProvider()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(nibModels: [AboutTableViewCellModel.self])

        navigationItem.title = NSLocalizedString("profile_about_title", comment: "")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        let cell = tableView.dequeueReusableCell(withAnyModel: model, for: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9529411765, blue: 0.9725490196, alpha: 1)
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataProvider.model(for: indexPath)
        let details = AboutDetails(rawValue: model.menuTitle)
        performSegue(withIdentifier: R.segue.aboutTableViewController.details, sender: details)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == R.segue.aboutTableViewController.details.identifier,
            let details = R.segue.aboutTableViewController.details(segue: segue) {
            details.destination.aboutDetails = sender as! AboutDetails
        }
    }
}

class AboutDataProvider {
    private lazy var dataSource: [AboutTableViewCellModel] = [
        AboutTableViewCellModel(menuTitle: AboutDetails.termsAndConditions.rawValue),
        AboutTableViewCellModel(menuTitle: AboutDetails.privacyPolicy.rawValue),
        AboutTableViewCellModel(menuTitle: AboutDetails.aboutThisApp.rawValue)
    ]

    func numberOfRows() -> Int {
        return dataSource.count
    }

    func model(for indexPath: IndexPath) -> AboutTableViewCellModel {
        return dataSource[indexPath.row]
    }
}
