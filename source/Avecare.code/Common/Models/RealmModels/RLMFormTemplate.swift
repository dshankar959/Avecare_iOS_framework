import Foundation
import RealmSwift
import CocoaLumberjack

class RLMFormTemplate: RLMDefaults {
    enum CodingKeys: String, CodingKey {
        case version
        case template
        case subjectType
    }

    @objc dynamic var version: Int = 0
    @objc dynamic var subjectType: String = ""
    @objc dynamic var organization: RLMOrganization?
    let rows = List<RLMLogRow>()

    override class func indexedProperties() -> [String] {
        return ["subjectType"]
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        do {
            try self.decode(from: decoder)
            let values = try decoder.container(keyedBy: CodingKeys.self)
            version = try values.decode(Int.self, forKey: .version)
            subjectType = try values.decode(String.self, forKey: .subjectType)
            let rows = try values.decode([RLMLogRow].self, forKey: .template)
            self.rows.append(objectsIn: rows)
        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

}

extension RLMFormTemplate: DataProvider, RLMCleanable {
    static func find(withSubjectType id: String) -> RLMFormTemplate? {
        return getDatabase()?.objects(RLMFormTemplate.self).filter("subjectType = %@", id).first
    }

    func clean() {
        // remove linked rows
        rows.forEach({ $0.clean() })
    }
}