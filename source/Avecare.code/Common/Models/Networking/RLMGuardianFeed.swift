import CocoaLumberjack
import RealmSwift

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

class RLMGuardianFeed: RLMDefaults {

    @objc dynamic var body: String = ""
    @objc dynamic var date = Date()
    @objc dynamic var header: String = ""
    @objc dynamic var important: Bool = false
    @objc dynamic var subjectId: String = ""
    @objc dynamic var feedItemId: String = ""
    dynamic var feedItemType: FeedItemType = .unKnown

    var unitIds = List<String>()


    enum CodingKeys: String, CodingKey {
        case body
        case date
        case header
        case important
        case subjectId
        case feedItemId
        case feedItemType
    }


    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try self.decode(from: decoder)  // call base class for defaults.

            let values = try decoder.container(keyedBy: CodingKeys.self)

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


typealias GuardianFeedResponse = APIResponse<[RLMGuardianFeed]>

/*
struct Injury: Codable {
    let id: String
    let name: String
    let description: String
    let isActive: Bool
}

typealias InjuriesResponse = APIResponse<[Injury]>

struct InjuriesResponse: Codable {

}*/
