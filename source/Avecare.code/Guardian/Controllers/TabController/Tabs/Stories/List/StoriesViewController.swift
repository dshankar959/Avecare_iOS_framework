//
//  StoriesViewController.swift
//  guardian
//

import Foundation
import UIKit

class StoriesListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    lazy var dataProvider: StoriesDataProvider = {
      return DefaultStoriesDataProvider()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(nibModels: [
            StoriesTableViewCellModel.self,
            SupervisorFilterTableViewCellModel.self
        ])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let details = R.segue.storiesListViewController.details(segue: segue) {
            details.destination.details = sender as? StoriesDetails
        }
    }
}

extension StoriesListViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows(for: section)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        let cell = tableView.dequeueReusableCell(withAnyModel: model, for: indexPath)
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
        return cell
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = .zero
        cell.layoutMargins = .zero
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }

        let details = dataProvider.details(at: indexPath)
        performSegue(withIdentifier: R.segue.storiesListViewController.details, sender: details)
    }
}
