import CocoaLumberjack
import RealmSwift

class RLMActivity: RLMDefaults {

    @objc dynamic var name: String = ""
    @objc dynamic var descriptions: String = ""
    @objc dynamic var isActive: Bool = false

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case isActive
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try self.decode(from: decoder)  // call base class for defaults.

            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.name = try values.decode(String.self, forKey: .name)
            self.descriptions = try values.decode(String.self, forKey: .description)
            self.isActive = try values.decode(Bool.self, forKey: .isActive)
        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }
}

extension RLMActivity: SingleValuePickerItem, DataProvider {
    var pickerTextValue: String {
        return name
    }
}

typealias RLMActivitiesResponse = APIResponse<[RLMActivity]>
