import Foundation
import CocoaLumberjack



struct InstitutionsAPIService {

    static func getInstitutionDetails(id: String,
                                      completion: @escaping (Result<RLMInstitution, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.institutionDetails(id: id)) { result in
//                            callbackQueue: DispatchQueue.main) { result in
//                            callbackQueue: DispatchQueue.global(qos: .default)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(InstitutionDetailsResponse.self)
                    completion(.success(mappedResponse))

//                    DispatchQueue.main.async() {
//                        completion(.success(mappedResponse))
//                    }

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
