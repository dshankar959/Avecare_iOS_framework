import CocoaLumberjack
import RealmSwift



class RLMUnit: Object, Decodable {

    @objc dynamic var id: Int = -1
    @objc dynamic var institutionId: Int = -1
    @objc dynamic var name: String = ""


    enum CodingKeys: String, CodingKey {
        case id
        case institutionId
        case name
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }

    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try values.decode(Int.self, forKey: .id)
            self.institutionId = try values.decode(Int.self, forKey: .institutionId)
            self.name = try values.decode(String.self, forKey: .name)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }

    }

    override class func primaryKey() -> String? {
        return "id"
    }


}


extension RLMUnit: DataProvider {
    typealias T = RLMUnit


    func details(for unitId: Int) -> RLMUnit? {
        return self.find(withID: unitId)
    }


}

typealias UnitDetailsResponse = RLMUnit
