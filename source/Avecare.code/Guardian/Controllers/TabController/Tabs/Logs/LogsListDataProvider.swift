import Foundation

protocol LogsDataProvider: class {
    func numberOfRows(for section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel
}

class DefaultLogsDataProvider: LogsDataProvider {

    lazy var dataSource: [RLMLogRow] = {
        do {
            return try createRealmDataSource()
        } catch {
            print(error)
            fatalError(error.localizedDescription)
        }
    }()

    func numberOfRows(for section: Int) -> Int {
        return dataSource.count
    }

    func model(for indexPath: IndexPath) -> AnyCellViewModel {
        return LogsViewModelFactory.viewModel(for: dataSource[indexPath.row])
    }
}

extension DefaultLogsDataProvider {
    private func createRealmDataSource() throws -> [RLMLogRow] {
        let data = try Data(resource: R.file.form1Json)
        let form = try JSONDecoder().decode(RLMLogForm.self, from: data)
        return Array(form.rows)
    }
}
