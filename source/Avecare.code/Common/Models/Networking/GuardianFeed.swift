import Foundation
import CocoaLumberjack


enum FeedItemType: String, Decodable {
    case message
    case subjectDailyLog = "subjectdailylog"
    case subjectInjury = "subjectinjury"
    case subjectReminder = "subjectreminder"
    case unitActivity = "unitactivity"
    case unKnown

    init(from decoder: Decoder) throws {
        self = try FeedItemType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unKnown
    }
}

struct GuardianFeed: Decodable {
    let id: String
    let body: String
    var date: Date
    let header: String
    let important: Bool
    let subjectId: String
    let feedItemId: String
    let feedItemType: FeedItemType

    enum CodingKeys: String, CodingKey {
        case id
        case body
        case date
        case header
        case important
        case subjectId
        case feedItemId
        case feedItemType
    }

    init(from decoder: Decoder) {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try values.decode(String.self, forKey: .id)
            self.body = try values.decode(String.self, forKey: .body)

            let dateString: String = try values.decode(String.self, forKey: .date)
            guard let date = Date.dateFromISO8601String(dateString) else {
                fatalError("JSON Decoding error = 'Invalid date format'")
            }
            self.date = date
            self.header = try values.decode(String.self, forKey: .header)
            self.important = try values.decode(Bool.self, forKey: .important)
            self.subjectId = try values.decode(String.self, forKey: .subjectId)
            self.feedItemId = try values.decode(String.self, forKey: .feedItemId)
            self.feedItemType = try values.decode(FeedItemType.self, forKey: .feedItemType)
        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }
}

typealias GuardianFeedResponse = APIResponse<[GuardianFeed]>
