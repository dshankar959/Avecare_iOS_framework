import CocoaLumberjack
import RealmSwift



class RLMInstitution: RLMDefaults {

    @objc dynamic var isActive: Bool = true
    @objc dynamic var organizationId: String = ""
    @objc dynamic var name: String = ""

    enum CodingKeys: String, CodingKey {
        case isActive
        case organizationId
        case name
        case mealPlan
        case activities = "eventsCalendar"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try self.decode(from: decoder)  // call base class for defaults.

            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.isActive = try values.decode(Bool.self, forKey: .isActive)
            self.organizationId = try values.decode(String.self, forKey: .organizationId)
            self.name = try values.decode(String.self, forKey: .name)
            if let mealPlan = try values.decodeIfPresent(String.self, forKey: .mealPlan),
                let url = URL(string: mealPlan) {
                _ = try DocumentService().savePDF(url, name: CodingKeys.mealPlan.rawValue)
            }
            if let activities = try values.decodeIfPresent(String.self, forKey: .activities),
                let url = URL(string: activities) {
                _ = try DocumentService().savePDF(url, name: CodingKeys.activities.rawValue)
            }

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

}


extension RLMInstitution {
    func mealPlanURL(using storage: DocumentService) -> URL? {
        return storage.PDFURL(name: CodingKeys.mealPlan.rawValue)
    }

    func activityURL(using storage: DocumentService) -> URL? {
        return storage.PDFURL(name: CodingKeys.activities.rawValue)
    }
}


extension RLMInstitution: DataProvider {

    static func details(for institutionId: String) -> RLMInstitution? {
        return RLMInstitution.find(withID: institutionId)
    }


}

typealias InstitutionDetailsResponse = RLMInstitution
