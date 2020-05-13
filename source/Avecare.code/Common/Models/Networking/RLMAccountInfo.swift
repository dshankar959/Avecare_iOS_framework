import CocoaLumberjack
import RealmSwift



class RLMAccountInfo: RLMDefaults {

    @objc dynamic var accountType: String? = nil


    enum CodingKeys: String, CodingKey {
        case accountType
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try self.decode(from: decoder)  // call base class for defaults.

            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.accountType = try values.decodeIfPresent(String.self, forKey: .accountType)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

}


extension RLMAccountInfo: DataProvider {
    typealias T = RLMAccountInfo


    static func saveAccountInfo(for accountType: String, with accountTypeId: String) {
        let accountInfo = RLMAccountInfo()
        accountInfo.accountType = accountType
        accountInfo.id = accountTypeId
        RLMAccountInfo().createOrUpdateAll(with: [accountInfo])
    }

}
