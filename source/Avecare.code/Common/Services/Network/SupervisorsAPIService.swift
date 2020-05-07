import Foundation
import CocoaLumberjack



struct SupervisorsAPIService {

    static func getSupervisorDetails(for supervisorId: Int,
                                     completion: @escaping (Result<RLMSupervisor, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.supervisorDetails(id: supervisorId)) { result in
            switch result {
            case .success(let response):
                do {
                    let detailsResponse = try response.map(SupervisorDetailsResponse.self)
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

}
