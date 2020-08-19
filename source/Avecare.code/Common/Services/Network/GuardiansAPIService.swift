import Foundation
import CocoaLumberjack



struct GuardiansAPIService {

    static func getGuardianDetails(for guardianId: String,
                                   completion: @escaping (Result<RLMGuardian, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.guardianDetails(id: guardianId),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let detailsResponse = try response.map(GuardianDetailsResponse.self)
                    DispatchQueue.main.async() {
                        completion(.success(detailsResponse))
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


    static func getGuardianFeed(for guardianId: String,
                                completion: @escaping (Result<[GuardianFeed], AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.guardianFeed(id: guardianId),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(GuardianFeedResponse.self)
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


    static func getSubjects(for guardianId: String,
                            completion: @escaping (Result<[RLMSubject], AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.guardianSubjects(id: guardianId),
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

}
