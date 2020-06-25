import Foundation
import CocoaLumberjack


struct FeedsAPIService {

    static func getMessage(for messageId: String,
                           completion: @escaping (Result<RLMMessage, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.message(id: messageId)) { result in
            switch result {
            case .success(let response):
                do {
                    let messageResponse = try response.map(RLMMessageResponse.self)
                    completion(.success(messageResponse))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        }
    }

    static func getActivity(for activityId: String,
                            completion: @escaping (Result<RLMActivity, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.unitActivity(id: activityId)) { result in
            switch result {
            case .success(let response):
                do {
                    let activityResponse = try response.map(RLMActivityResponse.self)
                    completion(.success(activityResponse))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        }
    }

    static func getInjury(for injuryId: String,
                          completion: @escaping (Result<RLMInjury, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.subjectInjury(id: injuryId)) { result in
            switch result {
            case .success(let response):
                do {
                    let injuryResponse = try response.map(RLMInjuryResponse.self)
                    completion(.success(injuryResponse))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        }
    }

    static func getReminder(for reminderId: String,
                            completion: @escaping (Result<RLMReminder, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.subjectReminder(id: reminderId)) { result in
            switch result {
            case .success(let response):
                do {
                    let reminderResponse = try response.map(RLMReminderResponse.self)
                    completion(.success(reminderResponse))
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
