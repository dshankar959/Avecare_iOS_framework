import Foundation

protocol ValidateSessionProtocol {
    func isSessionValid(_ completion: (Bool) -> Void)
}

class ValidateSessionMockService: ValidateSessionProtocol {
    func isSessionValid(_ completion: (Bool) -> Void) {
        completion(false)
    }
}
