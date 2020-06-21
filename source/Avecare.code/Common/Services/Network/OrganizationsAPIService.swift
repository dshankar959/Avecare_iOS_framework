import Foundation
import CocoaLumberjack



struct OrganizationsAPIService {

    static func getOrganizationDetails(id: String, completion: @escaping (Result<RLMOrganization, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.organizationDetails(id: id)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(OrganizationDetailsResponse.self)
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


    typealias LogTemplatesResult = APIPaginatedResponse<RLMFormTemplate>
    typealias LogTemplatesCompletion = (Result<[RLMFormTemplate], AppError>) -> Void
    static func getOrganizationLogTemplates(id: String, completion: @escaping LogTemplatesCompletion) {
        DDLogVerbose("")

        apiProvider.request(.organizationDailyTemplates(id: id)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(LogTemplatesResult.self)
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


    static func getAvailableDailyTasks(for organizationId: String, completion: @escaping (Result<[RLMDailyTask], AppError>) -> Void) {
            DDLogVerbose("")

            apiProvider.request(.organizationDailyTasks(id: organizationId)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(RLMDailyTasksResponse.self)
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


    static func getAvailableActivities(for organizationId: String, completion: @escaping (Result<[RLMActivity], AppError>) -> Void) {
            DDLogVerbose("")

            apiProvider.request(.organizationActivities(id: organizationId)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(RLMActivitiesResponse.self)
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


    static func getAvailableInjuries(for organizationId: String, completion: @escaping (Result<[RLMInjury], AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.organizationInjuries(id: organizationId)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(RLMInjuriesResponse.self)
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


    static func getAvailableReminders(organizationId: String,
                                      completion: @escaping (Result<[RLMReminder], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.organizationReminders(id: organizationId)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(RLMRemindersResponse.self)
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
