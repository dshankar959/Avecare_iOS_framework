import Foundation

protocol FeedDetailsDataProvider: class {
    func fetchMessage(with messageId: String, completion: @escaping (RLMMessage?, AppError?) -> Void)
    func fetchActivity(with activityId: String, completion: @escaping (RLMActivity?, AppError?) -> Void)
    func fetchInjury(with injuryId: String, completion: @escaping (RLMInjury?, AppError?) -> Void)
    func fetchReminder(with reminderId: String, completion: @escaping (RLMReminder?, AppError?) -> Void)
}

class DefaultFeedDetailsDataProvider: FeedDetailsDataProvider {
    func fetchMessage(with messageId: String, completion: @escaping (RLMMessage?, AppError?) -> Void) {
        FeedsAPIService.getMessage(for: messageId) { result in
            switch result {
            case .success(let message):
                completion(message, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func fetchActivity(with activityId: String, completion: @escaping (RLMActivity?, AppError?) -> Void) {
        FeedsAPIService.getActivity(for: activityId) { result in
            switch result {
            case .success(let activity):
                completion(activity, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func fetchInjury(with injuryId: String, completion: @escaping (RLMInjury?, AppError?) -> Void) {
        FeedsAPIService.getInjury(for: injuryId) { result in
            switch result {
            case .success(let injury):
                completion(injury, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }

    func fetchReminder(with reminderId: String, completion: @escaping (RLMReminder?, AppError?) -> Void) {
        FeedsAPIService.getReminder(for: reminderId) { result in
            switch result {
            case .success(let reminder):
                completion(reminder, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
