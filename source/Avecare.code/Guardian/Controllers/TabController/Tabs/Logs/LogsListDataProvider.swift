import Foundation
import CocoaLumberjack
import CocoaLumberjack


protocol LogsDataProvider: class {
    func numberOfRows(for section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel

    func fetchLogForm(subject: RLMSubject, date: Date)
}


class DefaultLogsDataProvider: LogsDataProvider {

    var logForm: RLMLogForm?
    let imageStorage = ImageStorageService()

    func numberOfRows(for section: Int) -> Int {
        return logForm?.rows.count ?? 0
    }

    func model(for indexPath: IndexPath) -> AnyCellViewModel {
        guard let model = logForm?.rows[indexPath.row] else {
            DDLogError("Tried to access invalid Index")
            fatalError("Tried to access invalid Index")
        }
        return LogsViewModelFactory.viewModel(for: model, storage: imageStorage)
    }

    func fetchLogForm(subject: RLMSubject, date: Date) {
        logForm = RLMLogForm.find(withSubjectID: subject.id, date: date)
    }
}
