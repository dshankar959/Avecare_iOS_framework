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


    static func getSupervisorAccounts(unitId: String,
                                      completion: @escaping (Result<[SupervisorAccount], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitSupervisors(id: unitId)) { result in
//                            callbackQueue: DispatchQueue.global(qos: .default)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(APIPaginatedResponse<SupervisorAccount>.self)
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

    static func publishStory(_ story: PublishStoryRequestModel, completion: @escaping (Result<FilesResponseModel, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitPublishStory(story: story)) { result in
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

    static func getPublishedStories(unitId: String, completion: @escaping (Result<[RLMStory], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitPublishedStories(unitId: unitId)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(APIPaginatedResponse<PublishStoryResponseModel>.self)
                    let storage = ImageStorageService()
                    var stories = [RLMStory]()
                    for model in mappedResponse.results {
                        stories.append(model.story)
                        if let file = model.files.first, file.id == model.story.id,
                           let url = URL(string: file.fileUrl) {
                            _ = try storage.saveRemoteFile(url, name: model.story.id, type: "pdf")
                        }
                    }
                    completion(.success(stories))
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
