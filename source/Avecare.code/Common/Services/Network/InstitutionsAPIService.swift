import Foundation
import CocoaLumberjack



struct InstitutionsAPIService {

    static func getInstitutionDetails(id: String,
                                      completion: @escaping (Result<RLMInstitution, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.institutionDetails(id: id),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(InstitutionDetailsResponse.self)
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

}
