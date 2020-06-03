import Foundation

protocol FeedDetailsDataProvider: class {
    func fetchMessage(with messageId: String, completion: @escaping (RLMMessage?, AppError?) -> Void)
}

class DefaultFeedDetailsDataProvider: FeedDetailsDataProvider {
    func fetchMessage(with messageId: String, completion: @escaping (RLMMessage?, AppError?) -> Void) {
        MessagesAPIService.getMessages(for: messageId) { result in
            switch result {
            case .success(let message):
                completion(message, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
