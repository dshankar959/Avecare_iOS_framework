import Foundation
import UIKit

class StoriesSideViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    lazy var dataProvider: StoriesDataProviderIO = {
        let provider = StoriesDataProvider()
        provider.delegate = self
        return provider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(nibModels: [
            StoriesTableViewCellModel.self
        ])

        if dataProvider.numberOfRows > 0 {
            dataProvider.setSelected(true, at: IndexPath(row: 0, section: 0))
        }

        dataProvider.fetchAll()
    }
}

extension StoriesSideViewController: UITableViewDelegate, UITableViewDataSource {
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

extension StoriesSideViewController: StoriesDataProviderDelegate {
    func didUpdateModel(at indexPath: IndexPath, details: Bool) {
        let model = dataProvider.model(for: indexPath)

        if let cell = tableView.cellForRow(at: indexPath) {
            model.setup(cell: cell)
        }

        if details, model.isSelected, let detailsViewController = customSplitController?.rightViewController as? DetailsFormViewController {
            let form = dataProvider.form(at: indexPath)
            detailsViewController.detailsView.setFormViews(form.viewModels)
            detailsViewController.navigationHeaderView.items = dataProvider.navigationItems(at: indexPath)
        }
    }

    func didCreateNewStory() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .top)
        dataProvider.setSelected(true, at: indexPath)
    }

    func moveStory(at fromIndexPath: IndexPath, to toIndexPath: IndexPath) {
        tableView.moveRow(at: fromIndexPath, to: toIndexPath)
    }
}
