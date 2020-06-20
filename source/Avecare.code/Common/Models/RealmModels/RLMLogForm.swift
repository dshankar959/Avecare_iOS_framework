import CocoaLumberjack
import RealmSwift



class RLMLogForm: RLMDefaults, RLMPublishable {

    @objc dynamic var subject: RLMSubject?
    @objc dynamic var rawPublishState: Int = PublishState.local.rawValue    // RLMPublishable protocol var(s)

    let rows = List<RLMLogRow>()


    enum CodingKeys: String, CodingKey {
        case subject
        case rows
    }

    override func decode(from decoder: Decoder) throws {
        do {
            try super.decode(from: decoder)
            let values = try decoder.container(keyedBy: CodingKeys.self)

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

    override func encode(to encoder: Encoder) throws {
        do {
            try super.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)

            // rows
            var rowsContainer = container.nestedUnkeyedContainer(forKey: .rows)
            for row in self.rows {
                try rowsContainer.encode(row)
            }
        } catch {
            DDLogError("JSON Encoding error = \(error)")
            fatalError("JSON Encoding error = \(error)")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rows.forEach({ $0.prepareForReuse() })
    }

}


extension RLMLogForm: DataProvider, RLMCleanable {

    static func find(withSubjectID: String, date: Date) -> Self? {
        let database = getDatabase()
        return database?.objects(Self.self).filter("subject.id = %@ AND serverLastUpdated = %@", withSubjectID, date).first
    }

    func clean() {
        rows.forEach { row in
            row.clean()
        }
    }
}
