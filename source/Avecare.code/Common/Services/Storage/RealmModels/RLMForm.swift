import Foundation
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

    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        localDate = try container.decodeIfPresent(Date.self, forKey: .localDate)
        serverDate = try container.decodeIfPresent(Date.self, forKey: .serverDate)
        subject = try container.decodeIfPresent(RLMSubject.self, forKey: .subject)
        if let rows = try container.decodeIfPresent([RLMLogRow].self, forKey: .rows) {
            self.rows.append(objectsIn: rows)
        }
    }

}


extension RLMLogForm: DataProvider {
    typealias T = RLMLogForm
}
