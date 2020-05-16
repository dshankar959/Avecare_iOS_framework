import Foundation
import RealmSwift

class RLMLogInjuryRow: Object, Decodable, FormRowIconProtocol {
    enum CodingKeys: String, CodingKey {
        case time
    }

    @objc dynamic var iconName = ""
    @objc dynamic var iconColor: Int32 = 0

    @objc dynamic var time = Date()

    required convenience init(from decoder: Decoder) throws {
        self.init()
        try decodeIcon(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let formatter = Date.timeFormatter
        if let timeString = try container.decodeIfPresent(String.self, forKey: .time),
        let time = formatter.date(from: timeString) {
            self.time = time
        }
    }
}

extension RLMLogInjuryRow: Encodable {
    func encode(to encoder: Encoder) throws {
        try encodeIcon(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        let formatter = Date.timeFormatter
        try container.encode(formatter.string(from: time), forKey: .time)
    }
}

extension RLMLogInjuryRow: DataProvider {

}
