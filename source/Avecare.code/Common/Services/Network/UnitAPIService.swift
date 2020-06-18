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


    static func publishStory(_ story: PublishStoryRequestModel, completion: @escaping (Result<RLMStory, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitPublishStory(story: story)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(RLMStory.self)
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

        let request = PublishedStoriesRequestModel(id: unitId)

        apiProvider.request(.unitPublishedStories(request: request)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(APIPaginatedResponse<RLMStory>.self)
                    let storage = DocumentService()
                    var stories = [RLMStory]()

                    for story in mappedResponse.results {
                        stories.append(story)

                        if let storyFileURL = story.storyFileURL, let url = URL(string: storyFileURL) {
                            _ = try storage.saveRemoteFile(url, name: story.id, type: "pdf")
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

        apiProvider.request(.unitCreateActivity(id: uintId,request: data), completion: { result in
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
