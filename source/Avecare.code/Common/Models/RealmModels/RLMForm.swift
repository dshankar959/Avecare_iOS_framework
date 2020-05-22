import CocoaLumberjack
import RealmSwift



class RLMLogForm: RLMDefaults, RLMPublishable {
    // RLMPublishable
    @objc dynamic var serverLastUpdated: Date?      // ISO8601 datetime stamp of last server-side change
    @objc dynamic var clientLastUpdated = Date()    // ISO8601 datetime stamp of last local change
    @objc dynamic var rawPublishState: Int = PublishState.local.rawValue

    @objc dynamic var subject: RLMSubject?

    let rows = List<RLMLogRow>()

    enum CodingKeys: String, CodingKey {
        case serverLastUpdated
        case clientLastUpdated
        case subject
        case rows
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)

        // dates
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: clientLastUpdated), forKey: .clientLastUpdated)
        if let date = serverLastUpdated {
            try container.encodeIfPresent(formatter.string(from: date), forKey: .serverLastUpdated)
        }

        // rows
        var rowsContainer = container.nestedUnkeyedContainer(forKey: .rows)
        for row in self.rows {
            try rowsContainer.encode(row)
        }
    }

    override func decode(from decoder: Decoder) throws {
        do {
            try super.decode(from: decoder)
            let values = try decoder.container(keyedBy: CodingKeys.self)

            // dates
            let formatter = ISO8601DateFormatter()
            if let dateString = try values.decodeIfPresent(String.self, forKey: .clientLastUpdated),
                let date = formatter.date(from: dateString) {
                clientLastUpdated = date
            }
            if let dateString = try values.decodeIfPresent(String.self, forKey: .serverLastUpdated),
                let date = formatter.date(from: dateString) {
                serverLastUpdated = date
            }

            // not sure this needed
            subject = try values.decodeIfPresent(RLMSubject.self, forKey: .subject)

            // rows
            if let rows = try values.decodeIfPresent([RLMLogRow].self, forKey: .rows) {
                self.rows.append(objectsIn: rows)
            }
        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rows.forEach({ $0.prepareForReuse() })
    }
}


extension RLMLogForm: DataProvider {

    static func find(withSubjectID: String, date: Date) -> Self? {
        let database = getDatabase()
        return database?.objects(Self.self)
                .filter("subject.id = %@ AND serverLastUpdated = %@", withSubjectID, date)
                .first
    }

}
