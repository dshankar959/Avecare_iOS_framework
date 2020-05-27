import UIKit



class LogsSideViewController: UIViewController {

    @IBOutlet weak var sortSegmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    lazy var dataProvider: SubjectListDataProviderIO = {
        let provider = SubjectListDataProvider()
        provider.delegate = self
        return provider
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        didChangeSegmentControl(sortSegmentControl)

        // select first row by default
        if dataProvider.numberOfRows > 0 {
            dataProvider.setSelected(true, at: IndexPath(row: 0, section: 0))
        }
    }

    @IBAction func didChangeSegmentControl(_ sender: UISegmentedControl) {
        guard let sort = SubjectListDataProvider.Sort(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        dataProvider.sortBy(sort)
        tableView.reloadData()
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
