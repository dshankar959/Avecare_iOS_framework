import CocoaLumberjack
import RealmSwift

class RLMLogForm: Object, Codable {
    enum CodingKeys: String, CodingKey {
        case localDate = "clientLastUpdated"
        case serverDate = "serverLastUpdated"
        case subject
        case rows
    }

    // last change date
    @objc dynamic var localDate = Date() // iso8601
    // submit date
    @objc dynamic var serverDate: Date? // iso8601
    @objc dynamic var subject: RLMSubject?

    let rows = List<RLMLogRow>()

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try decode(from: decoder)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        // dates
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: localDate), forKey: .localDate)
        if let date = serverDate {
            try container.encodeIfPresent(formatter.string(from: date), forKey: .serverDate)
        }

        // rows
        var rowsContainer = container.nestedUnkeyedContainer(forKey: .rows)
        for row in self.rows {
            try rowsContainer.encode(row)
        }
    }

    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            // dates
            let formatter = ISO8601DateFormatter()
            if let dateString = try values.decodeIfPresent(String.self, forKey: .localDate),
               let date = formatter.date(from: dateString) {
                localDate = date
            }
            if let dateString = try values.decodeIfPresent(String.self, forKey: .serverDate),
               let date = formatter.date(from: dateString) {
                serverDate = date
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
}


extension RLMLogForm: DataProvider {

}
