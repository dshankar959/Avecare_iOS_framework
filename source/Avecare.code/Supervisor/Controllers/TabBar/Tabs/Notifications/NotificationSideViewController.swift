import UIKit



class NotificationSideViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    lazy var dataProvider: NotificationTypeDataProvider = {
        let provider = DefaultNotificationTypeDataProvider()
        provider.delegate = self
        provider.presentationController = self
        return provider
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(nibModels: [NotificationTypeTableViewCellModel.self])

        if dataProvider.numberOfRows > 0 {
            dataProvider.setSelected(true, at: IndexPath(row: 0, section: 0))
        }
    }

}


extension NotificationSideViewController: UITableViewDelegate, UITableViewDataSource {

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


extension NotificationSideViewController: NotificationTypeDataProviderDelegate, IndicatorProtocol {

    func showAlert(title: String, message: String) {
        let error = AppError(title: title, userInfo: message, code: "", type: "")
        self.showErrorAlert(error)
    }

    func didUpdateModel(at indexPath: IndexPath) {
        let model = dataProvider.model(for: indexPath)

        if let cell = tableView.cellForRow(at: indexPath) {
            model.setup(cell: cell)
        }

        if model.isSelected, let detailsViewController = customSplitController?.rightViewController as? DetailsFormViewController {
            let form = dataProvider.loadForm(at: indexPath)
            detailsViewController.detailsView.setFormViews(form.viewModels)
            detailsViewController.navigationHeaderView.items = dataProvider.navigationItems(at: indexPath, type: model.type)
        }
    }

}
