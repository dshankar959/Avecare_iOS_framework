import Foundation
import CocoaLumberjack



struct InstitutionsAPIService {

    static func getInstitutionDetails(id: Int,
                                      completion: @escaping (Result<InstitutionDetails, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.institutionDetails(id: id)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(InstitutionDetailsResponse.self)
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

}
