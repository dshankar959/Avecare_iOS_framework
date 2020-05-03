//
//  LogsViewController.swift
//  guardian
//

import Foundation
import UIKit

class LogsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    let dataProvider = DefaultLogsDataProvider()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(nibModels: [
            LogsOptionTableViewCellModel.self,
            LogsTimeDetailsTableViewCellModel.self,
            LogsNoteTableViewCellModel.self,
            LogsPhotoTableViewCellModel.self
        ])
    }
}

extension LogsViewController: UITableViewDelegate, UITableViewDataSource {
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
}
