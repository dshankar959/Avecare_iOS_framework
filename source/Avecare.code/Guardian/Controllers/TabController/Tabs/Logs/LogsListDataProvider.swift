import Foundation
import CocoaLumberjack


protocol LogsDataProvider: class {
    var datesWithData: Set<Date> { get }
    func numberOfRows(for section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel

    func fetchDailyLogsForChild(with subjectId: String)
    func fetchDailyLog(with logId: String) -> (String, Date?)
}


class DefaultLogsDataProvider: LogsDataProvider {

    private let imageStorage = ImageStorageService()
    private var dailyLogForDate: [Date: RLMLogForm] = [:]

    var datesWithData: Set<Date> = []
    var selectedDate: Date = Date()

    func numberOfRows(for section: Int) -> Int {
        return dailyLogForDate[selectedDate]?.rows.count ?? 0
    }

    func model(for indexPath: IndexPath) -> AnyCellViewModel {
        guard let selectedLog = dailyLogForDate[selectedDate]?.rows[indexPath.row] else {
            DDLogError("Tried to access invalid Index")
            fatalError("Tried to access invalid Index")
        }
        return LogsViewModelFactory.viewModel(for: selectedLog, storage: imageStorage)
    }

    func fetchDailyLogsForChild(with subjectId: String) {
        datesWithData.removeAll()
        dailyLogForDate.removeAll()
        let dailyLogs = RLMLogForm.findAll(withSubjectID: subjectId)
        dailyLogs.forEach { dailyLog in
            if let dateOfLog = dailyLog.serverLastUpdated?.startOfDay {
                datesWithData.insert(dateOfLog)
                dailyLogForDate[dateOfLog] = dailyLog
            }
        }
    }

    func fetchDailyLog(with logId: String) -> (String, Date?) {
        let logForm = RLMLogForm.find(withID: logId)
        let logDate = logForm?.serverLastUpdated?.startOfDay
        selectedDate = logDate ?? Date()
        let subjectId = logForm?.subject?.id ?? ""
        fetchDailyLogsForChild(with: subjectId)
        return (subjectId, selectedDate)
    }
}
