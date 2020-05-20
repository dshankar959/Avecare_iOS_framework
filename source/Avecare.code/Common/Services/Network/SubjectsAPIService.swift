import Foundation
import CocoaLumberjack


struct SubjectsAPIService {
    static func publishDailyLog(log: DailyFormAPIModel, completion: @escaping (Result<FilesResponseModel, AppError>) -> Void) {
        apiProvider.request(.subjectPublishDailyLog(request: log)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(FilesResponseModel.self)
                    completion(.success(mappedResponse))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        }
    }

    struct SubjectLogsRequest {
        let subjectId: String
        private let date: Date?

        init(id: String, date: Date? = nil) {
            self.subjectId = id
            self.date = date
        }

        var formattedDate: String? {
            guard let date = date else {
                return nil
            }
            return Date.yearMonthDayFormatter.string(from: date)
        }
    }

    static func getLogs(request: SubjectLogsRequest, completion: @escaping (Result<[DailyFormAPIModel], AppError>) -> Void) {
        apiProvider.request(.subjectGetLogs(request: request)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(APIPaginatedResponse<DailyFormAPIModel>.self)
                    completion(.success(mappedResponse.results))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        }
    }
}
