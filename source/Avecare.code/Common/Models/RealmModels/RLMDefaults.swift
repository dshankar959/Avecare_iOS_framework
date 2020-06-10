import CocoaLumberjack
import RealmSwift



class RLMDefaults: Object, Codable, RLMReusable {

    @objc dynamic var id: String = ""
    @objc dynamic var serverLastUpdated: Date?      // ISO8601 datetime stamp of last server-side change
    @objc dynamic var clientLastUpdated: Date?      // ISO8601 datetime stamp of last local change

//    @objc dynamic var sync: Bool = false


    private enum DefaultCodingKeys: String, CodingKey {
        case id
        case serverLastUpdated = "updatedAt"
        case clientLastUpdated
    }


    convenience required init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }


    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: DefaultCodingKeys.self)

            if let id = try values.decodeIfPresent(String.self, forKey: .id)?.lowercased() {
                self.id = id
            } else {
                self.id = newUUID
                DDLogWarn("🆔 self assigned id [\(self.id)]")
            }

            // dates
            if let dateString = try values.decodeIfPresent(String.self, forKey: .clientLastUpdated),
                let date = Date.dateFromISO8601String(dateString) {
                clientLastUpdated = date
            } else {
                if try values.decodeIfPresent(String.self, forKey: .clientLastUpdated) != nil {
                    DDLogWarn("Failed to convert `clientLastUpdated` date.  This is problematic.")
                }
            }
            if let dateString = try values.decodeIfPresent(String.self, forKey: .serverLastUpdated),
                let date = Date.dateFromISO8601String(dateString) {
                serverLastUpdated = date
            } else {
                if try values.decodeIfPresent(String.self, forKey: .serverLastUpdated) != nil {
                    DDLogWarn("Failed to convert `serverLastUpdated` date.  This is problematic.")
                }
            }

//            self.syncToken = try values.decode(String.self, forKey: .syncToken)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }


    func encode(to encoder: Encoder) throws {
        do {
            var values = encoder.container(keyedBy: DefaultCodingKeys.self)

            try values.encodeIfPresent(id.lowercased(), forKey: .id)

            // dates
            if let date = clientLastUpdated {
                try values.encodeIfPresent(Date.ISO8601StringFromDate(date), forKey: .clientLastUpdated)
            }
            if let date = serverLastUpdated {
                try values.encodeIfPresent(Date.ISO8601StringFromDate(date), forKey: .serverLastUpdated)
            }

        } catch {
            DDLogError("JSON encoding error = \(error)")
            fatalError("JSON encoding error = \(error)")
        }

    }


    override static func primaryKey() -> String {
        return "id"
    }

    convenience init(id: String) {
        self.init()

        self.id = id
        self.clientLastUpdated = Date()
    }

    func prepareForReuse() {
        id = newUUID
    }

}


extension RLMDefaults {

    static func == (lhs: RLMDefaults, rhs: RLMDefaults) -> Bool {
        var equal: Bool = false

        if !lhs.id.isEmpty, !rhs.id.isEmpty {
            if lhs.id.caseInsensitiveCompare(rhs.id) == .orderedSame {
                // returns true if 'value1' equals 'value2' (case insensitive)
                equal = true
            }
        }

       return equal
    }

}
