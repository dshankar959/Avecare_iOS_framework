import CocoaLumberjack



struct SubjectsAPIService {

    struct SubjectLogsRequest {
        var subjectId: String = ""
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


        init(id: String? = nil) {
            guard let subjectId = id else {
                return
            }

            self.subjectId = subjectId

            let allDailyLogForms = RLMLogForm.findAll(withSubjectID: subjectId)
            let sortedDailyLogForms = RLMLogForm.sortObjectsByLastUpdated(order: .orderedDescending, allDailyLogForms)
            let publishedDailyLogForms = sortedDailyLogForms.filter { $0.rawPublishState == PublishState.published.rawValue }

            if appSession.userProfile.isGuardian,
                let lastUpdated = publishedDailyLogForms.first?.serverLastUpdated {
                serverLastUpdated = Date.ISO8601StringFromDate(lastUpdated)
            }
        }

    }


    // MARK: -
    static func publishDailyLog(log: LogFormAPIModel, completion: @escaping (Result<LogFormAPIModel, AppError>) -> Void) {
        let subjectName = RLMSubject.find(withID: log.subjectId)?.fullName ?? "<RLMSubject>"
        DDLogVerbose("Publish daily log [id:\(log.id)] for subject: \"\(subjectName)\" [\(log.subjectId)]")

        apiProvider.request(.subjectPublishDailyLog(request: log),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                DDLogVerbose("Success ✅ publishing daily log [id:\(log.id)] for subject: \"\(subjectName)\" [\(log.subjectId)]")
                DispatchQueue.main.async() {
                    do {
                        let mappedResponse = try response.map(LogFormAPIModel.self)
                        completion(.success(mappedResponse))
                    } catch {
                        DDLogError("JSON MAPPING ERROR = \(error)")
                        completion(.failure(JSONError.failedToMapData.message))
                    }
                }
            case .failure(let error):
                DDLogVerbose("Failed ❌ to publish daily log [id:\(log.id)] for subject: \"\(subjectName)\" [\(log.subjectId)]")

                let underlyingError = getAppErrorFromMoya(with: error)

                if underlyingError.code == HTTPerror.code_409 { // "Log for this date and subject already exists"
                    DDLogVerbose("👍 Server already contains published daily log [id:\(log.id)] for subject: \"\(subjectName)\" [\(log.subjectId)]")
                    DispatchQueue.main.async() {
                        completion(.success(log))   // set it and forget it.
                    }
                } else {
                    DispatchQueue.main.async() {
                        completion(.failure(underlyingError))
                    }
                }
            }
        }
    }


    static func getLogs(request: SubjectLogsRequest, completion: @escaping (Result<[LogFormAPIModel], AppError>) -> Void) {
        apiProvider.request(.subjectGetLogs(request: request),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async() {
                    do {
                        let mappedResponse = try response.map(APIPaginatedResponse<LogFormAPIModel>.self)
                        completion(.success(mappedResponse.results))
                    } catch {
                        DDLogError("JSON MAPPING ERROR = \(error)")
                        completion(.failure(JSONError.failedToMapData.message))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async() {
                    completion(.failure(getAppErrorFromMoya(with: error)))
                }
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
