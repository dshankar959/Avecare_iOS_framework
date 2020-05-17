import Foundation
import RealmSwift

class RLMLogTimeRow: Object, Decodable, FormRowIconProtocol {
    enum CodingKeys: String, CodingKey {
        case title
        case startTime
        case endTime
    }

    @objc dynamic var iconName = ""
    @objc dynamic var iconColor: Int32 = 0

    @objc dynamic var title = ""
    @objc dynamic var startTime = Date()
    @objc dynamic var endTime = Date(timeIntervalSinceNow: 30 * 60)

    required convenience init(from decoder: Decoder) throws {
        self.init()
        try decodeIcon(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)

        let formatter = Date.timeFormatter
        if let timeString = try container.decodeIfPresent(String.self, forKey: .startTime),
           let time = formatter.date(from: timeString) {
            startTime = time
        }
        if let timeString = try container.decodeIfPresent(String.self, forKey: .endTime),
           let time = formatter.date(from: timeString) {
            endTime = time
        }
    }
}

extension RLMLogTimeRow: Encodable {
    func encode(to encoder: Encoder) throws {
        try encodeIcon(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        let formatter = Date.timeFormatter
        try container.encode(title, forKey: .title)
        try container.encode(formatter.string(from: startTime), forKey: .startTime)
        try container.encode(formatter.string(from: endTime), forKey: .endTime)
    }
}

extension RLMLogTimeRow: DataProvider {

}
