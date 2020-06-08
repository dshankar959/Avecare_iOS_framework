import RealmSwift
import CocoaLumberjack



class RLMLogNoteRow: Object, Decodable, FormRowIconProtocol {

    enum CodingKeys: String, CodingKey {
        case title
        case value
    }

    @objc dynamic var iconName = ""
    @objc dynamic var iconColor: Int32 = 0

    @objc dynamic var title = ""
    @objc dynamic var value: String? = nil

    required convenience init(from decoder: Decoder) throws {
        self.init()
        try decodeIcon(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        value = try container.decodeIfPresent(String.self, forKey: .value)
    }
}

extension RLMLogNoteRow: Encodable {
    func encode(to encoder: Encoder) throws {
        try encodeIcon(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(value, forKey: .value)
    }
}

extension RLMLogNoteRow: DataProvider {

}
