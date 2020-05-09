import CocoaLumberjack
import RealmSwift



class RLMInstitution: Object, Decodable {

    @objc dynamic var id: Int = -1
    @objc dynamic var isActive: Bool = true
    @objc dynamic var organizationId: Int = -1
    @objc dynamic var name: String = ""
    @objc dynamic private var mealPlan: String? = nil
    @objc dynamic private var activities: String? = nil

    var mealPlanURL: URL? { // PDF
        return URL(string: mealPlan ?? "")
    }

    var activitiesURL: URL? { // PDF
        return URL(string: activities ?? "")
    }


    enum CodingKeys: String, CodingKey {
        case id
        case isActive
        case organizationId
        case name
        case mealPlan
        case activities
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }

    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try values.decode(Int.self, forKey: .id)
            self.isActive = try values.decode(Bool.self, forKey: .isActive)
            self.organizationId = try values.decode(Int.self, forKey: .organizationId)
            self.name = try values.decode(String.self, forKey: .name)
            self.mealPlan = try values.decodeIfPresent(String.self, forKey: .mealPlan)
            self.activities = try values.decodeIfPresent(String.self, forKey: .activities)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    override class func primaryKey() -> String? {
        return "id"
    }

}


extension RLMInstitution: DataProvider {
    typealias T = RLMInstitution

    static func details(for institutionId: Int) -> RLMInstitution? {
        return RLMInstitution().find(withID: institutionId)
    }


}

typealias InstitutionDetailsResponse = RLMInstitution
