import Foundation
import CocoaLumberjack



struct UnitAPIService {

    static func getUnitDetails(unitId: Int,
                               completion: @escaping (Result<RLMUnit, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.unitDetails(id: unitId)) { result in
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


    static func getDailyTasks(unitId: Int,
                              completion: @escaping (Result<[DailyTask], AppError>) -> Void) {
        DDLogDebug("")

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


    static func getSubjects(unitId: Int,
                            completion: @escaping (Result<[RLMSubject], AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.unitSubjects(id: unitId)) { result in
            switch result {
            case .success(let response):
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(Date.ymdFormatter)
                    let mappedResponse = try response.map(RLMSubjectResponse.self, using: decoder)
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


    static func getActivities(unitId: Int,
                              completion: @escaping (Result<[UnitActivity], AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.unitActivities(id: unitId)) { result in
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


    static func getReminders(unitId: Int,
                             completion: @escaping (Result<[UnitReminder], AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.unitReminders(id: unitId)) { result in
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


}