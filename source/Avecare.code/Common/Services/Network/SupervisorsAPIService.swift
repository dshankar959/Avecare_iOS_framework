import Foundation
import CocoaLumberjack



struct SupervisorsAPIService {

    static func getSupervisorDetails(for supervisorId: String,
                                     completion: @escaping (Result<RLMSupervisor, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.supervisorDetails(id: supervisorId),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    let detailsResponse = try response.map(SupervisorDetailsResponse.self)
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

}
