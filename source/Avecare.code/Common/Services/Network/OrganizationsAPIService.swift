import Foundation
import CocoaLumberjack



struct OrganizationsAPIService {

    static func getOrganizationDetails(id: String, completion: @escaping (Result<RLMOrganization, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.organizationDetails(id: id),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(OrganizationDetailsResponse.self)
                    DispatchQueue.main.async() {
                        completion(.success(mappedResponse))
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
        }
    }


    typealias LogTemplatesResult = APIPaginatedResponse<RLMFormTemplate>
    typealias LogTemplatesCompletion = (Result<[RLMFormTemplate], AppError>) -> Void
    static func getOrganizationLogTemplates(id: String, completion: @escaping LogTemplatesCompletion) {
        DDLogVerbose("")

        apiProvider.request(.organizationDailyTemplates(id: id),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(LogTemplatesResult.self)
                    DispatchQueue.main.async() {
                        completion(.success(mappedResponse.results))
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
        }
    }


    static func getAvailableDailyTasks(for organizationId: String, completion: @escaping (Result<[RLMDailyTaskOption], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.organizationDailyTasks(id: organizationId),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(RLMDailyTasksResponse.self)
                    DispatchQueue.main.async() {
                        completion(.success(mappedResponse.results))
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
        }
    }


    static func getAvailableActivities(for organizationId: String, completion: @escaping (Result<[RLMActivityOption], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.organizationActivities(id: organizationId),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(RLMActivitiesResponse.self)
                    DispatchQueue.main.async() {
                        completion(.success(mappedResponse.results))
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
        }
    }


    static func getAvailableInjuries(for organizationId: String, completion: @escaping (Result<[RLMInjuryOption], AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.organizationInjuries(id: organizationId),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(RLMInjuriesResponse.self)
                    DispatchQueue.main.async() {
                        completion(.success(mappedResponse.results))
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
        }
    }


    static func getAvailableReminders(organizationId: String,
                                      completion: @escaping (Result<[RLMReminderOption], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.organizationReminders(id: organizationId),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(RLMRemindersResponse.self)
                    DispatchQueue.main.async() {
                        completion(.success(mappedResponse.results))
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
        }
    }

}
