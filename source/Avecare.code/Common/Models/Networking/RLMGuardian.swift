import CocoaLumberjack
import RealmSwift


class RLMGuardian: RLMDefaults {

    @objc dynamic var isActive: Bool = true
    @objc dynamic var homePhoneNumber: String = ""
    @objc dynamic var workPhoneNumber: String = ""
    @objc dynamic var mobilePhoneNumber: String = ""


    enum CodingKeys: String, CodingKey {
        case isActive
        case homePhoneNumber
        case workPhoneNumber
        case mobilePhoneNumber
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try self.decode(from: decoder)  // call base class for defaults.

            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.isActive = try values.decode(Bool.self, forKey: .isActive)
            self.homePhoneNumber = try values.decode(String.self, forKey: .homePhoneNumber)
            self.workPhoneNumber = try values.decode(String.self, forKey: .workPhoneNumber)
            self.mobilePhoneNumber = try values.decode(String.self, forKey: .mobilePhoneNumber)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

}


extension RLMGuardian: DataProvider {
    typealias T = RLMGuardian


    static var details: RLMGuardian? {
        if let id = appSession.userProfile.accountTypeId {
            return RLMGuardian.find(withID: id)
        }

        return nil
    }

}

typealias GuardianDetailsResponse = RLMGuardian
