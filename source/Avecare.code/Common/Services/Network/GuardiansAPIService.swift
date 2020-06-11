import Foundation
import CocoaLumberjack



struct GuardiansAPIService {

    static func getGuardianDetails(for guardianId: String,
                                   completion: @escaping (Result<RLMGuardian, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.guardianDetails(id: guardianId)) { result in
            switch result {
            case .success(let response):
                do {
                    let detailsResponse = try response.map(GuardianDetailsResponse.self)
                    completion(.success(detailsResponse))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        }
    }


    static func getGuardianFeed(for guardianId: String,
                                completion: @escaping (Result<[GuardianFeed], AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.guardianFeed(id: guardianId)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(GuardianFeedResponse.self)
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


    static func getSubjects(for guardianId: String,
                            completion: @escaping (Result<[RLMSubject], AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.guardianSubjects(id: guardianId)) { result in
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

}
