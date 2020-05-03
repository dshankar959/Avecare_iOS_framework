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

        if let time = try container.decodeIfPresent(Date.self, forKey: .startTime) {
            startTime = time
        }
        if let time = try container.decodeIfPresent(Date.self, forKey: .endTime) {
            endTime = time
        }
    }
}


extension RLMLogTimeRow: DataProvider {
    typealias T = RLMLogTimeRow
}
