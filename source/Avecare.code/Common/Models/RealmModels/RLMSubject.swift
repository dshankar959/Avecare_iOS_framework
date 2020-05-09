import CocoaLumberjack
import RealmSwift



class RLMSubject: Object, Decodable {

    @objc dynamic var id: Int = -1
    @objc dynamic var firstName: String = ""
    @objc dynamic var middleName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var birthday = Date()
    @objc dynamic var subjectTypeId: Int = 0
    @objc dynamic var photoConsent: Bool = true
    @objc dynamic private var profilePhoto: String = ""

    var unitIds = List<Int>()

    var profilePhotoURL: URL? {
        return URL(string: profilePhoto)
    }

    let logForms = LinkingObjects(fromType: RLMLogForm.self, property: "subject")   // Inverse relationship


    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case middleName
        case lastName
        case birthday
        case subjectTypeId
        case photoConsent
        case profilePhoto
        case unitIds
    }


    convenience required init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }

    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try values.decode(Int.self, forKey: .id)
            self.firstName = try values.decode(String.self, forKey: .firstName)
            self.middleName = try values.decode(String.self, forKey: .middleName)
            self.lastName = try values.decode(String.self, forKey: .lastName)
            self.birthday = try values.decode(Date.self, forKey: .birthday)
            self.subjectTypeId = try values.decode(Int.self, forKey: .subjectTypeId)
            self.photoConsent = try values.decode(Bool.self, forKey: .photoConsent)
            self.profilePhoto = try values.decode(String.self, forKey: .profilePhoto)
            self.unitIds = try values.decode(List<Int>.self, forKey: .unitIds)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}


extension RLMSubject: DataProvider {
    typealias T = RLMSubject
}


typealias RLMSubjectResponse = APIResponse<[RLMSubject]>
