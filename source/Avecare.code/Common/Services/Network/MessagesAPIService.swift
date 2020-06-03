import Foundation
import CocoaLumberjack


struct MessagesAPIService {

    static func getMessages(for messageId: String,
                            completion: @escaping (Result<RLMMessage, AppError>) -> Void) {
        DDLogDebug("")

        apiProvider.request(.messages(id: messageId)) { result in
            switch result {
            case .success(let response):
                do {
                    let messageResponse = try response.map(MessageResponse.self)
                    completion(.success(messageResponse))
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
