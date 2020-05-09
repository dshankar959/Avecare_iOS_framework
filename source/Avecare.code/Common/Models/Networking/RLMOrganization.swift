import CocoaLumberjack
import RealmSwift



class RLMOrganization: Object, Decodable {

    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""


    enum CodingKeys: String, CodingKey {
        case id
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


extension RLMOrganization: DataProvider {
    typealias T = RLMOrganization
}

typealias OrganizationDetailsResponse = RLMOrganization
