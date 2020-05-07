import Foundation
import CocoaLumberjack



struct AccountsAPIService {

    static func accountInfo(completion: @escaping (Result<RLMAccountInfo, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.accountInfo) { result in
            switch result {
            case .success(let response):
                do {
                    let accountInfoResponse = try response.map(AccountInfoResponse.self)
                    completion(.success(accountInfoResponse.results))
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
