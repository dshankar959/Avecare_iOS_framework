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
        var serverLastUpdated: String = ""

        var startDate: String {
            let startDate: Date
            if appSession.userProfile.isSupervisor {
                startDate = Date()  // for supervisor to sync down just today's date
            } else {
                startDate = startDateOfLogsHistory
            }
            return Date.yearMonthDayFormatter.string(from: startDate)
        }

        var endDate: String {
            return Date.yearMonthDayFormatter.string(from: endDateOfLogsHistory)
        }

        init(id: String) {
            self.subjectId = id

            let allDailyLogForms = RLMLogForm.findAll(withSubjectID: id)
            let sortedDailyLogForms = RLMLogForm.sortObjectsByLastUpdated(order: .orderedDescending, allDailyLogForms)
            let publishedDailyLogForms = sortedDailyLogForms.filter { $0.rawPublishState == PublishState.published.rawValue }

            if appSession.userProfile.isGuardian,
                let lastUpdated = publishedDailyLogForms.first?.serverLastUpdated {
                serverLastUpdated = Date.ISO8601StringFromDate(lastUpdated)
            }
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
