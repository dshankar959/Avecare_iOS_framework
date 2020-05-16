import CocoaLumberjack
import RealmSwift



class RLMDefaults: Object, Codable {

    @objc dynamic var id: String = ""
//    @objc dynamic var serverLastUpdated: String? = nil
//    @objc dynamic var clientLastUpdated: String? = nil
//    @objc dynamic var syncToken: String = DALconfig.defaultSyncToken
//    @objc dynamic var sync: Bool = false



    private enum DefaultCodingKeys: String, CodingKey {
        case id
//        case serverLastUpdated = "server_last_updated"
//        case clientLastUpdated = "client_last_updated"
//        case syncToken = "sync_token"
    }


    convenience required init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }


    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: DefaultCodingKeys.self)

            self.id = try values.decode(String.self, forKey: .id).lowercased()
//            self.serverLastUpdated = try values.decodeIfPresent(String.self, forKey: .serverLastUpdated)
//            self.clientLastUpdated = try values.decodeIfPresent(String.self, forKey: .clientLastUpdated)
//            self.syncToken = try values.decode(String.self, forKey: .syncToken)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DefaultCodingKeys.self)
        try container.encode(id.lowercased(), forKey: .id)
    }

    override static func primaryKey() -> String {
        return "id"
    }


    convenience init(id: String) {
        self.init()
        self.id = id
    }

}
