import Foundation
import RealmSwift

class RLMLogOptionRow: Object, Decodable, FormRowIconProtocol {
    enum CodingKeys: String, CodingKey {
        case title
        case placeholder
        case selectedValue
        case options
    }

    @objc dynamic var iconName = ""
    @objc dynamic var iconColor: Int32 = 0

    @objc dynamic var title = ""
    @objc dynamic var placeholder = ""
    let selectedValue = RealmOptional<Int>()
    let options = List<RLMOptionValue>()

    required convenience init(from decoder: Decoder) throws {
        self.init()
        try decodeIcon(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        placeholder = try container.decode(String.self, forKey: .placeholder)
        selectedValue.value = try container.decodeIfPresent(Int.self, forKey: .selectedValue)
        if let options = try container.decodeIfPresent([RLMOptionValue].self, forKey: .options) {
            self.options.append(objectsIn: options)
        }
    }
}


extension RLMLogOptionRow: DataProvider, RLMCleanable {
    typealias T = RLMLogOptionRow

    func clean() {
        deleteAll(objects: Array(options))
        delete()
    }
}
