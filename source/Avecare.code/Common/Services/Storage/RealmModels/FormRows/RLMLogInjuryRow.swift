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
        if let time = try container.decodeIfPresent(Date.self, forKey: .time) {
            self.time = time
        }
    }
}


extension RLMLogInjuryRow: DataProvider {
    typealias T = RLMLogInjuryRow
}
