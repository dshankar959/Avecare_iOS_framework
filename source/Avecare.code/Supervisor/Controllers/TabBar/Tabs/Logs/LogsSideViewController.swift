import UIKit
import RealmSwift



class LogsSideViewController: UIViewController {

    @IBOutlet weak var sortSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    lazy var dataProvider: SubjectListDataProviderIO = {
        let provider = SubjectListDataProvider()
        provider.delegate = self
        return provider
    }()

    // DB update notifications
    private var dbNotificationsToken: NotificationToken? = nil


    override func viewDidLoad() {
        super.viewDidLoad()

        didChangeSegmentControl(sortSegmentControl)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // select first row by default only when setected id is not set before
        if dataProvider.numberOfRows > 0 &&  dataProvider.selectedId == nil {
            dataProvider.setSelected(true, at: IndexPath(row: 0, section: 0))
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        dbNotifications(true)
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        dbNotifications(false)
    }


    @IBAction func didChangeSegmentControl(_ sender: UISegmentedControl) {
        guard let sort = SubjectListDataProvider.Sort(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        dataProvider.sortBy(sort)
        tableView.reloadData()
    }

    deinit {
    }
}


extension LogsSideViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        return tableView.dequeueReusableCell(withModel: model, for: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataProvider.setSelected(true, at: indexPath)
    }

}


extension LogsSideViewController: SubjectListDataProviderDelegate {

    func didUpdateModel(at indexPath: IndexPath) {
        let model = dataProvider.model(for: indexPath)
        if let cell = tableView.cellForRow(at: indexPath) {
            model.setup(cell: cell)
        }

        if model.isSelected, let detailsViewController = customSplitController?.rightViewController as? DetailsFormViewController {
            detailsViewController.updateSyncButton()
            let form = dataProvider.form(at: indexPath)
            detailsViewController.detailsView.setFormViews(form.viewModels)
            detailsViewController.navigationHeaderView.items = dataProvider.navigationItems(at: indexPath)
        }
    }

    func didFailure(_ error: Error) {
    }

}


extension LogsSideViewController: CustomResponderProvider {

    var customResponder: CustomResponder? {
        guard let detailsViewController = customSplitController?.rightViewController as? DetailsFormViewController else { return nil }
        return detailsViewController.detailsView
    }

}


extension LogsSideViewController {

    func dbNotifications(_ enable: Bool) {
        if enable {
            if dbNotificationsToken == nil {
//                DDLogDebug("[RLMLogForm] dbNotifications: ON 🔔")
                dbNotificationsToken = RLMLogForm().setupNotificationToken(for: self) { [weak self] in
                    if let segmentControl = self?.sortSegmentControl {
                        self?.didChangeSegmentControl(segmentControl)
                        self?.tableView.reloadData()
                    }
                }
            }
        } else {  // disable
//            DDLogDebug("[RLMLogForm] dbNotifications: OFF 🔕")
            dbNotificationsToken?.invalidate()
            dbNotificationsToken = nil
        }
    }

}
