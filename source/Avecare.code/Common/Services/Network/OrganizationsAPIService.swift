import Foundation
import CocoaLumberjack



struct OrganizationsAPIService {

    static func getOrganizationDetails(id: Int,
                                       completion: @escaping (Result<RLMOrganization, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.organizationDetails(id: id)) { result in
            switch result {
            case .success(let response):
                do {
                    let mappedResponse = try response.map(OrganizationDetailsResponse.self)
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
