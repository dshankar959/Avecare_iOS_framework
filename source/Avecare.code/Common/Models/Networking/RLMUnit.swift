import CocoaLumberjack
import RealmSwift



class RLMUnit: RLMDefaults {

    @objc dynamic var institutionId: String = ""
    @objc dynamic var name: String = ""


    enum CodingKeys: String, CodingKey {
        case institutionId
        case name
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try self.decode(from: decoder)  // call base class for defaults.

            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.institutionId = try values.decode(String.self, forKey: .institutionId)
            self.name = try values.decode(String.self, forKey: .name)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

}


extension RLMUnit: DataProvider {
    typealias T = RLMUnit

    static func details(for unitId: String) -> RLMUnit? {
        return RLMUnit().find(withID: unitId)
    }


}

typealias UnitDetailsResponse = RLMUnit
