import Foundation
import CocoaLumberjack

enum PublishState: Int, Codable {
    case local = 0          // client side record
    case publishing = 1     // need to send to the server
    case published = 2      // sent to the server and received response
}

protocol RLMPublishable: class {
    // ISO8601 datetime stamp of last server-side change
    var serverLastUpdated: Date? { get set }
    // ISO8601 datetime stamp of last local change
    var clientLastUpdated: Date { get set }
    var rawPublishState: Int { get set }
}

extension RLMPublishable {
    var publishState: PublishState {
        get {
            guard let state = PublishState(rawValue: rawPublishState) else {
                DDLogError("RLMStory.rawPublishState invalid value")
                fatalError("RLMStory.rawPublishState invalid value")
            }
            return state
        }
        set {
            rawPublishState = newValue.rawValue
        }
    }
}