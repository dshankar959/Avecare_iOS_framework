import Foundation
import CocoaLumberjack



struct UnitAPIService {

    static func getUnitDetails(unitId: String,
                               completion: @escaping (Result<RLMUnit, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitDetails(id: unitId),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(UnitDetailsResponse.self)
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


    static func getSubjects(unitId: String,
                            completion: @escaping (Result<[RLMSubject], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitSubjects(id: unitId),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(SubjectsResponse.self)
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


    static func getSupervisorAccounts(unitId: String,
                                      completion: @escaping (Result<[SupervisorAccount], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitSupervisors(id: unitId),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(APIPaginatedResponse<SupervisorAccount>.self)
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


    static func publishStory(_ story: PublishStoryRequestModel, completion: @escaping (Result<RLMStory, AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitPublishStory(story: story),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(RLMStory.self)
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


    static func getPublishedStories(unitId: String, completion: @escaping (Result<[RLMStory], AppError>) -> Void) {
        DDLogVerbose("")

        let request = PublishedStoriesRequestModel(id: unitId)

        apiProvider.request(.unitPublishedStories(request: request),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
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

                    DispatchQueue.main.async() {
                        completion(.success(stories))
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


extension UnitAPIService {

    struct DailyTaskFormsRequest {
        let unitId: String
        var serverLastUpdated: String = ""

        var startDate: String {
            return Date.yearMonthDayFormatter.string(from: Date())
        }

        var endDate: String {
            return Date.yearMonthDayFormatter.string(from: Date())
        }


        init(unitId: String) {
            self.unitId = unitId
        }

    }


    static func getPublishedDailyTaskForms(request: DailyTaskFormsRequest, completion: @escaping (Result<[RLMDailyTaskForm], AppError>) -> Void) {
        DDLogVerbose("")

        apiProvider.request(.unitPublishedDailyTaskForms(request: request),
        callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(APIPaginatedResponse<RLMDailyTaskForm>.self)

                    var publishedDailyTaskForms = [RLMDailyTaskForm]()

                    for checklist in mappedResponse.results {
                        publishedDailyTaskForms.append(checklist.detached())
                    }

                    DispatchQueue.main.async() {
                        completion(.success(publishedDailyTaskForms))
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
