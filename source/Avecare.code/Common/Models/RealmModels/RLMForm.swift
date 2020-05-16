import CocoaLumberjack
import RealmSwift



class RLMLogForm: Object, Decodable {

    @objc dynamic var serverLastUpdated: Date?      // datetime stamp of last server-side change
    @objc dynamic var clientLastUpdated = Date()    // datetime stamp of last local change
    @objc dynamic var subject: RLMSubject?

    let rows = List<RLMLogRow>()


    enum CodingKeys: String, CodingKey {
        case serverLastUpdated
        case clientLastUpdated
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

            if let date = try values.decodeIfPresent(Date.self, forKey: .clientLastUpdated) {
                clientLastUpdated = date
            }

            serverLastUpdated = try values.decodeIfPresent(Date.self, forKey: .serverLastUpdated)
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
