import Foundation
import CocoaLumberjack



struct UnitAPIService {

    static func getUnitDetails(id: Int, completion: @escaping (Result<UnitDetails, AppError>) -> Void) {
        apiProvider.request(.unitDetails(id: id)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(UnitDetailsResponse.self)
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


    static func getDailyTasks(unitId: Int, completion: @escaping (Result<[DailyTask], AppError>) -> Void) {
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


    static func getSubjects(id: Int, completion: @escaping (Result<[RLMSubject], AppError>) -> Void) {
        apiProvider.request(.unitSubjects(id: id)) { result in
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


    static func getActivities(id: Int, completion: @escaping (Result<[UnitActivity], AppError>) -> Void) {
        apiProvider.request(.unitActivities(id: id)) { result in
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


    static func getReminders(id: Int, completion: @escaping (Result<[UnitReminder], AppError>) -> Void) {
        apiProvider.request(.unitReminders(id: id)) { result in
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
