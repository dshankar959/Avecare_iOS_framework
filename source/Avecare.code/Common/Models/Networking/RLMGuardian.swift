import CocoaLumberjack
import RealmSwift



class RLMGuardian: Object, Decodable {

    @objc dynamic var id: Int = -1
    @objc dynamic var isActive: Bool = true
    @objc dynamic var homePhoneNumber: String = ""
    @objc dynamic var workPhoneNumber: String = ""
    @objc dynamic var mobilePhoneNumber: String = ""


    enum CodingKeys: String, CodingKey {
        case id
        case isActive
        case homePhoneNumber
        case workPhoneNumber
        case mobilePhoneNumber
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }

    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try values.decode(Int.self, forKey: .id)
            self.isActive = try values.decode(Bool.self, forKey: .isActive)
            self.homePhoneNumber = try values.decode(String.self, forKey: .homePhoneNumber)
            self.workPhoneNumber = try values.decode(String.self, forKey: .workPhoneNumber)
            self.mobilePhoneNumber = try values.decode(String.self, forKey: .mobilePhoneNumber)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    override class func primaryKey() -> String? {
        return "id"
    }

}


extension RLMGuardian: DataProvider {
    typealias T = RLMGuardian


    var details: RLMGuardian? {
        if let id = appSession.userProfile.accountTypeId {
            return self.find(withID: id)
        }

        return nil
    }

}

typealias GuardianDetailsResponse = APIResponse<RLMGuardian>
