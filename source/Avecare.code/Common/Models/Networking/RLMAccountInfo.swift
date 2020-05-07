import CocoaLumberjack
import RealmSwift



class RLMAccountInfo: Object, Decodable {

    @objc dynamic var id: Int = -1
    @objc dynamic var accountType: String? = nil


    enum CodingKeys: String, CodingKey {
        case id = "accountTypeId"
        case accountType
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }

    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try values.decode(Int.self, forKey: .id)
            self.accountType = try values.decodeIfPresent(String.self, forKey: .accountType)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }

    }

    override class func primaryKey() -> String? {
        return "id"
    }


}


extension RLMAccountInfo: DataProvider {
    typealias T = RLMAccountInfo


    static func saveAccountInfo(for accountType: String, with accountTypeId: Int) {
        let accountInfo = RLMAccountInfo()
        accountInfo.accountType = accountType
        accountInfo.id = accountTypeId
        RLMAccountInfo().createOrUpdateAll(with: [accountInfo])
    }

}
