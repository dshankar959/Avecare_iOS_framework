import Foundation
import RealmSwift

class RLMLogSwitcherRow: Object, Decodable, FormRowIconProtocol {
    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case startTime
        case endTime
        case selectedValue
        case options
    }

    @objc dynamic var iconName = ""
    @objc dynamic var iconColor: Int32 = 0

    @objc dynamic var title = ""
    @objc dynamic var subtitle = ""
    @objc dynamic var startTime = Date()
    @objc dynamic var endTime = Date(timeIntervalSinceNow: 30 * 60)

    let selectedValue = RealmOptional<Int>()
    let options = List<RLMOptionValue>()

    required convenience init(from decoder: Decoder) throws {
        self.init()
        try decodeIcon(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        selectedValue.value = try container.decodeIfPresent(Int.self, forKey: .selectedValue)
        if let time = try container.decodeIfPresent(Date.self, forKey: .startTime) {
            startTime = time
        }
        if let time = try container.decodeIfPresent(Date.self, forKey: .endTime) {
            endTime = time
        }
        if let options = try container.decodeIfPresent([RLMOptionValue].self, forKey: .options) {
            self.options.append(objectsIn: options)
        }
    }
}

extension RLMLogSwitcherRow: DataProvider, RLMCleanable {
    typealias T = RLMLogSwitcherRow

    func clean() {
        self.deleteAll(objects: Array(options))
        self.delete()
    }
}
