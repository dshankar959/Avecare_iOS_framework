import Foundation
import CocoaLumberjack


struct NotificationsAPIService {

    static func publishDailyTaskForm(unitId: String, data: RLMDailyTaskForm, completion: @escaping (Result<RLMDailyTaskForm, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitPublishDailyTaskForm(id: unitId, request: data),
                            callbackQueue: DispatchQueue.global(qos: .utility),
                            completion: { result in
                                switch result {
                                case .success(let response):
                                    do {
                                        let dailyTaskForm = try JSONDecoder().decode(RLMDailyTaskForm.self, from: response.data)
                                        DispatchQueue.main.async() {
                                            completion(.success(dailyTaskForm))
                                        }
                                    } catch {
                                        DDLogError("JSON MAPPING ERROR = \(error)")
                                        DispatchQueue.main.async() {
                                            completion(.failure(JSONError.failedToMapData.message))
                                        }
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async() {
                                        completion(.failure(getAppErrorFromMoya(with: error)))
                                    }
                                }
        })
    }

    static func publishReminders(data: [RLMReminder], completion: @escaping (Result<[RLMReminder], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitCreateReminder(payLoad: data),
                            callbackQueue: DispatchQueue.global(qos: .utility),
                            completion: { result in
                                switch result {
                                case .success(let response):
                                    do {
                                        let reminders = try JSONDecoder().decode([RLMReminder].self, from: response.data)
                                        DispatchQueue.main.async() {
                                            completion(.success(reminders))
                                        }
                                    } catch {
                                        DDLogError("JSON MAPPING ERROR = \(error)")
                                        DispatchQueue.main.async() {
                                            completion(.failure(JSONError.failedToMapData.message))
                                        }
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async() {
                                        completion(.failure(getAppErrorFromMoya(with: error)))
                                    }
                                }
        })
    }

    static func publishActivity(uintId: String, data: RLMActivity, completion: @escaping (Result<RLMActivity, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitCreateActivity(id: uintId, request: data),
                            callbackQueue: DispatchQueue.global(qos: .utility),
                            completion: { result in
                                switch result {
                                case .success(let response):
                                    do {
                                        let activity = try JSONDecoder().decode(RLMActivity.self, from: response.data)
                                        DispatchQueue.main.async() {
                                            completion(.success(activity))
                                        }
                                    } catch {
                                        DDLogError("JSON MAPPING ERROR = \(error)")
                                        DispatchQueue.main.async() {
                                            completion(.failure(JSONError.failedToMapData.message))
                                        }
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async() {
                                        completion(.failure(getAppErrorFromMoya(with: error)))
                                    }
                                }
        })
    }

    static func publishInjuries(data: [RLMInjury], completion: @escaping (Result<[RLMInjury], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitCreateInjury(payLoad: data),
                            callbackQueue: DispatchQueue.global(qos: .utility),
                            completion: { result in
                                switch result {
                                case .success(let response):
                                    do {
                                        let injuries = try JSONDecoder().decode([RLMInjury].self, from: response.data)
                                        DispatchQueue.main.async() {
                                            completion(.success(injuries))
                                        }
                                    } catch {
                                        DDLogError("JSON MAPPING ERROR = \(error)")
                                        DispatchQueue.main.async() {
                                            completion(.failure(JSONError.failedToMapData.message))
                                        }
                                    }
                                case .failure(let error):
                                    DispatchQueue.main.async() {
                                        completion(.failure(getAppErrorFromMoya(with: error)))
                                    }
                                }
        })
    }
}
