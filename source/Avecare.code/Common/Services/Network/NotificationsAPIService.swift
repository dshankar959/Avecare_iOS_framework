import Foundation
import CocoaLumberjack


struct NotificationsAPIService {

    static func publishDailyTaskForm(unitId: String, data: RLMDailyTaskForm, completion: @escaping (Result<RLMDailyTaskForm, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitPublishDailyTaskForm(id: unitId, request: data), completion: { result in
            switch result {
            case .success(let response):
                do {
                    let dailyTaskForm = try JSONDecoder().decode(RLMDailyTaskForm.self, from: response.data)
                    completion(.success(dailyTaskForm))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        })
    }

    static func publishReminders(data: [RLMReminder], completion: @escaping (Result<[RLMReminder], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitCreateReminder(payLoad: data), completion: { result in
            switch result {
            case .success(let response):
                do {
                    let reminders = try JSONDecoder().decode([RLMReminder].self, from: response.data)
                    completion(.success(reminders))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        })
    }

    static func publishActivity(uintId: String, data: RLMActivity, completion: @escaping (Result<RLMActivity, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitCreateActivity(id: uintId, request: data), completion: { result in
            switch result {
            case .success(let response):
                do {
                    let activity = try JSONDecoder().decode(RLMActivity.self, from: response.data)
                    completion(.success(activity))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        })
    }

    static func publishInjuries(data: [RLMInjury], completion: @escaping (Result<[RLMInjury], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitCreateInjury(payLoad: data), completion: { result in
            switch result {
            case .success(let response):
                do {
                    let injuries = try JSONDecoder().decode([RLMInjury].self, from: response.data)
                    completion(.success(injuries))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        })
    }
}
