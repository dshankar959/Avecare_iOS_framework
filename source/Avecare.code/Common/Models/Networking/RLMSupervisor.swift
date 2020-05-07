import CocoaLumberjack
import RealmSwift



class RLMSupervisor: Object, Decodable {

    @objc dynamic var id: Int = -1
    @objc dynamic var title: String = ""
    @objc dynamic var firstName: String = ""
    @objc dynamic var middleName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var bio: String = ""
// TODO:  "educationalBackground":
    @objc dynamic var primaryUnitId: Int = -1
    @objc dynamic var profilePhoto: String = ""

    var profilePhotoURL: URL? {
        return URL(string: profilePhoto)
    }


    enum CodingKeys: String, CodingKey {
        case id
        case title
        case firstName
        case middleName
        case lastName
        case bio
        case primaryUnitId
        case profilePhoto
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }

    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.id = try values.decode(Int.self, forKey: .id)
            self.title = try values.decode(String.self, forKey: .title)
            self.firstName = try values.decode(String.self, forKey: .firstName)
            self.middleName = try values.decode(String.self, forKey: .middleName)
            self.lastName = try values.decode(String.self, forKey: .lastName)
            self.bio = try values.decode(String.self, forKey: .bio)
            self.primaryUnitId = try values.decode(Int.self, forKey: .primaryUnitId)
            self.profilePhoto = try values.decode(String.self, forKey: .profilePhoto)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }

    }

    override class func primaryKey() -> String? {
        return "id"
    }

}


extension RLMSupervisor: DataProvider {
    typealias T = RLMSupervisor


    var details: RLMSupervisor? {
        if let id = appSession.userProfile.accountTypeId {
            return self.find(withID: id)
        }

        return nil
    }

}

typealias SupervisorDetailsResponse = RLMSupervisor
