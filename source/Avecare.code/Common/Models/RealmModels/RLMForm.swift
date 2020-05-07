import CocoaLumberjack
import RealmSwift



class RLMLogForm: Object, Decodable {

    @objc dynamic var localDate: Date?
    @objc dynamic var serverDate: Date?

    @objc dynamic var subject: RLMSubject?

    let rows = List<RLMLogRow>()

    enum CodingKeys: String, CodingKey {
        case localDate = "clientLastUpdated"
        case serverDate = "serverLastUpdated"
        case subject
        case rows
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }

    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            localDate = try values.decodeIfPresent(Date.self, forKey: .localDate)
            serverDate = try values.decodeIfPresent(Date.self, forKey: .serverDate)
            subject = try values.decodeIfPresent(RLMSubject.self, forKey: .subject)
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
    typealias T = RLMLogForm
}
