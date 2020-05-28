import CocoaLumberjack



struct SubjectsAPIService {

    static func publishDailyLog(log: LogFormAPIModel, completion: @escaping (Result<FilesResponseModel, AppError>) -> Void) {
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

        var startDate: String {
            return Date.yearMonthDayFormatter.string(from: startDateOfLogsHistory)
        }

        var endDate: String {
            return Date.yearMonthDayFormatter.string(from: endDateOfLogsHistory)
        }

        init(id: String) {
            self.subjectId = id
        }
    }


    static func getLogs(request: SubjectLogsRequest, completion: @escaping (Result<[LogFormAPIModel], AppError>) -> Void) {
        apiProvider.request(.subjectGetLogs(request: request)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(APIPaginatedResponse<LogFormAPIModel>.self)
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


extension SubjectsAPIService {

    static var startDateOfLogsHistory: Date {
        let numberOfDays = 7    // window of time
        return Calendar.current.date(byAdding: .day, value: -numberOfDays, to: Date()) ?? Date()
    }

    static var endDateOfLogsHistory: Date {
        Date().next(.saturday, includingTheDate: true)
    }

}
