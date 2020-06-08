import CocoaLumberjack
import RealmSwift



class RLMSupervisor: RLMDefaults {

    @objc dynamic var title: String = ""
    @objc dynamic var firstName: String = ""
    @objc dynamic var middleName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var bio: String = ""
    @objc dynamic var primaryUnitId: String = ""

    var educationalBackground = List<RLMEducation>()


    enum CodingKeys: String, CodingKey {
        case title
        case firstName
        case middleName
        case lastName
        case bio
        case educationalBackground
        case primaryUnitId
        case profilePhoto
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try self.decode(from: decoder)  // call base class for defaults.

            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.title = try values.decode(String.self, forKey: .title)
            self.firstName = try values.decode(String.self, forKey: .firstName)
            self.middleName = try values.decode(String.self, forKey: .middleName)
            self.lastName = try values.decode(String.self, forKey: .lastName)
            self.bio = try values.decode(String.self, forKey: .bio)
            self.educationalBackground = try values.decode(List<RLMEducation>.self, forKey: .educationalBackground)
            self.primaryUnitId = try values.decode(String.self, forKey: .primaryUnitId)

            // load and save image during json response decoding synchronously
            if let profilePhoto = try values.decodeIfPresent(String.self, forKey: .profilePhoto),
               let url = URL(string: profilePhoto) {
                _ = try StorageService().saveRemoteFile(url, name: id, type: "jpg")
            }
        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }
}

extension RLMSupervisor {
    func photoURL(using storage: StorageService) -> URL? {
        return storage.fileURL(name: id, type: "jpg")
    }
}


extension RLMSupervisor: DataProvider, RLMCleanable {

    func clean() {
        // clear the linked list of objects only
        for item in educationalBackground {
            item.delete()
        }

//        delete()
    }

    static var details: RLMSupervisor? {
        if let id = appSession.userProfile.accountTypeId {
            return RLMSupervisor.find(withID: id)
        }

        return nil
    }

}

typealias SupervisorDetailsResponse = RLMSupervisor


// MARK: -
class RLMEducation: Object, Decodable {

    @objc dynamic var institute: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var yearCompleted: Int = -1

    enum CodingKeys: String, CodingKey {
        case institute
        case title
        case yearCompleted
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try self.decode(from: decoder)
    }

    func decode(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.institute = try values.decode(String.self, forKey: .institute)
            self.title = try values.decode(String.self, forKey: .title)
            self.yearCompleted = try values.decode(Int.self, forKey: .yearCompleted)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }
}


extension RLMEducation: DataProvider {
    typealias T = RLMEducation
}

// MARK: -

struct SupervisorAccount: Decodable {
    let supervisorId: String
    let isUnitType: Bool
    let showInUnitList: Bool

    enum CodingKeys: String, CodingKey {
        case supervisorId = "id"
        case isUnitType
        case showInUnitList
    }


    init(supervisorId: String = "", isUnitType: Bool = false, showInUnitList: Bool = false) {   // default struct initializer
        self.supervisorId = supervisorId
        self.isUnitType = isUnitType
        self.showInUnitList = showInUnitList
    }

    init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.supervisorId = try values.decode(String.self, forKey: .supervisorId)
            self.isUnitType = try values.decode(Bool.self, forKey: .isUnitType)
            self.showInUnitList = try values.decode(Bool.self, forKey: .showInUnitList)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

}
