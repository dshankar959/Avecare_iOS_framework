import Foundation
import CocoaLumberjack


enum FeedItemType: String, Codable {
    case message
    case subjectDailyLog = "subjectdailylog"
    case subjectInjury = "subjectinjury"
    case subjectReminder = "subjectreminder"
    case unitActivity = "unitactivity"
    case unitStory = "unitstory"
    case unKnown

    init(from decoder: Decoder) throws {
        self = try FeedItemType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unKnown
    }
}

struct GuardianFeed: Codable {
    let id: String
    let body: String
    var date: Date
    let header: String
    let important: Bool
    let subjectIds: [String]
    let feedItemId: String
    let feedItemType: FeedItemType

    enum CodingKeys: String, CodingKey {
        case id
        case body
        case date
        case header
        case important
        case subjectIds
        case feedItemId
        case feedItemType
    }

    init(from decoder: Decoder) {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try values.decode(String.self, forKey: .id)
            self.body = try values.decode(String.self, forKey: .body)

            let dateString: String = try values.decode(String.self, forKey: .date)
            if dateString.contains("T00:00:00") { // In case date only
                let dateOnlyString = dateString.components(separatedBy: "T").first ?? Date.logFormStringFromDate(Date())
                self.date = Date.dateFromLogFormString(dateOnlyString) ?? Date()
            } else {
                self.date = Date.dateFromISO8601String(dateString) ?? Date()
            }
            self.header = try values.decode(String.self, forKey: .header)
            self.important = try values.decode(Bool.self, forKey: .important)
            self.subjectIds = try values.decode([String].self, forKey: .subjectIds)
            self.feedItemId = try values.decode(String.self, forKey: .feedItemId)
            self.feedItemType = try values.decode(FeedItemType.self, forKey: .feedItemType)
        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        do {
            try container.encode(id, forKey: .id)
            try container.encode(body, forKey: .body)

            let dateString: String = Date.logFormStringFromDate(date) + "T00:00:00"
            try container.encode(dateString, forKey: .date)
            try container.encode(header, forKey: .header)
            try container.encode(important, forKey: .important)
            try container.encode(subjectIds, forKey: .subjectIds)
            try container.encode(feedItemId, forKey: .feedItemId)
            try container.encode(feedItemType, forKey: .feedItemType)
        } catch {
            DDLogError("JSON Encoding error = \(error)")
            fatalError("JSON Encoding error = \(error)")
        }
    }
}

typealias GuardianFeedResponse = APIResponse<[GuardianFeed]>
