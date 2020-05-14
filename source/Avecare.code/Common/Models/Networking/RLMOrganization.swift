import CocoaLumberjack
import RealmSwift



class RLMOrganization: RLMDefaults {

    @objc dynamic var name: String = ""


    enum CodingKeys: String, CodingKey {
        case name
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try self.decode(from: decoder)  // call base class for defaults.

            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.name = try values.decode(String.self, forKey: .name)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

}


extension RLMOrganization: DataProvider {
    static func details(for organizationId: String) -> RLMOrganization? {
        return RLMOrganization.find(withID: organizationId)
    }
}

typealias OrganizationDetailsResponse = RLMOrganization
