import Foundation
import CocoaLumberjack



struct UnitAPIService {

    static func getUnitDetails(unitId: String,
                               completion: @escaping (Result<RLMUnit, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitDetails(id: unitId)) { result in
//                            callbackQueue: DispatchQueue.main) { result in
//                            callbackQueue: DispatchQueue.global(qos: .default)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(UnitDetailsResponse.self)
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


    static func getDailyTasks(unitId: String,
                              completion: @escaping (Result<[DailyTask], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitDailyTasks(id: unitId)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(APIResponse<[DailyTask]>.self)
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


    static func getSubjects(unitId: String,
                            completion: @escaping (Result<[RLMSubject], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitSubjects(id: unitId)) { result in
//                            callbackQueue: DispatchQueue.global(qos: .default)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(SubjectsResponse.self)
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


    static func getActivities(unitId: String,
                              completion: @escaping (Result<[UnitActivity], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitActivities(id: unitId)) { result in
//                            callbackQueue: DispatchQueue.global(qos: .default)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(UnitActivityResponse.self)
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


    static func getReminders(unitId: String,
                             completion: @escaping (Result<[UnitReminder], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitReminders(id: unitId)) { result in
//                            callbackQueue: DispatchQueue.global(qos: .default)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(UnitReminderResponse.self)
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

    static func publishStory(_ story: StoryAPIModel, completion: @escaping (Result<FilesAPIResponseModel, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitPublishStory(story: story)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(APIResponse<FilesAPIResponseModel>.self)
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
