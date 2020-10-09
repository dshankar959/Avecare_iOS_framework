import CocoaLumberjack
import RealmSwift



class RLMFormTemplate: RLMDefaults {

    @objc dynamic var version: Int = 0
    @objc dynamic var subjectType: String = ""
    @objc dynamic var organization: String = ""

    let rows = List<RLMLogRow>()


    enum CodingKeys: String, CodingKey {
        case version
        case template
        case subjectType
        case organization
    }

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
            organization = try values.decode(String.self, forKey: .organization)

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
        let allFormTemplates = RLMFormTemplate.findAll()
        let result = allFormTemplates.filter { $0.subjectType == id }.sorted { $0.version > $1.version }.first

        return result
    }

    func clean() {
        // remove linked rows
        rows.forEach({ $0.clean() })
    }


}
