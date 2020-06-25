import CocoaLumberjack
import RealmSwift

enum MessageType: String, Decodable {
    case organization
    case institution
    case unit
    case subject
    case unKnown

    init(from decoder: Decoder) throws {
        self = try MessageType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unKnown
    }
}

class RLMMessage: RLMDefaults {

    @objc dynamic var header: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var body: String = ""
    @objc dynamic var fileURL: String?
    dynamic var contentType: MessageType = .unKnown


    enum CodingKeys: String, CodingKey {
        case header
        case title
        case body
        case file
        case createdAt
        case contentType
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try self.decode(from: decoder)  // call base class for defaults.

            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.header = try values.decode(String.self, forKey: .header)
            self.title = try values.decode(String.self, forKey: .title)
            self.body = try values.decode(String.self, forKey: .body)
            self.fileURL = try? values.decode(String.self, forKey: .file)

            let dateString: String = try values.decode(String.self, forKey: .createdAt)
            guard let date = Date.dateFromISO8601String(dateString) else {
                fatalError("JSON Decoding error = 'Invalid date format'")
            }
            self.serverLastUpdated = date

            self.contentType = try values.decode(MessageType.self, forKey: .contentType)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

}

typealias RLMMessageResponse = RLMMessage
