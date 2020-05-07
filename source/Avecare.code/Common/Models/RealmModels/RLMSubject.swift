import Foundation
import RealmSwift



class RLMSubject: Object, Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case middleName
        case lastName
        case birthday
        case subjectTypeId
    }

    @objc dynamic var id: Int = -1
    @objc dynamic var firstName: String = ""
    @objc dynamic var middleName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var birthday = Date()
    @objc dynamic var subjectTypeId: Int = 0

    let logForms = LinkingObjects(fromType: RLMLogForm.self, property: "subject")

    override class func primaryKey() -> String? {
        return "id"
    }
}


extension RLMSubject: DataProvider {
    typealias T = RLMSubject
}
