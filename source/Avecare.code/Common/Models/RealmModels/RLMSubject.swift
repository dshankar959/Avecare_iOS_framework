import CocoaLumberjack
import RealmSwift


class RLMSubject: RLMDefaults {

    @objc dynamic var firstName: String = ""
    @objc dynamic var middleName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var birthday = Date()
    @objc dynamic var subjectTypeId: String = ""
    @objc dynamic var photoConsent: Bool = true
    @objc dynamic private var profilePhoto: String? = nil

    var unitIds = List<String>()

    var profilePhotoURL: URL? {
        if let photoURL = profilePhoto {
            return URL(string: photoURL)
        }
        return nil
    }

    var isFormSubmittedToday: Bool {
        return todayForm.serverLastUpdated != nil
    }

    let logForms = LinkingObjects(fromType: RLMLogForm.self, property: "subject")   // Inverse relationship

    var todayForm: RLMLogForm {
/*
//        let mostRecentLogForm = logForms.sorted(byKeyPath: "clientLastUpdated", ascending: false).first

        // Collect the subjects log forms and sort by date last updated on device.
        let allLogForms: [RLMLogForm] = Array(logForms)
        let sortedLogForms = allLogForms.sorted(by: { $0.clientLastUpdated.compare($1.clientLastUpdated) == .orderedAscending})

        let mostRecentLogForm = RLMLogForm(value: sortedLogForms.last)

//        Calendar.current.isDateInToday(mostRecentLogForm.clientLastUpdated)
//        if let mostRecentLogForm = sortedLogForms.last, Calendar.current.isDateInToday(mostRecentLogForm.clientLastUpdated) {
//            return mostRecentLogForm
//        }

*/

        if let form = logForms.last, Calendar.current.isDateInToday(form.clientLastUpdated) {
            return form
        }

        DDLogDebug("Creating today's form for subject: [\(id)], \(firstName) \(lastName) ")
        let form = RLMLogForm()
        form.subject = self

        if let template = RLMFormTemplate.find(withSubjectType: subjectTypeId) {
            DDLogDebug("Loading template: \(template.id)")
            form.rows.append(objectsIn: template.rows.detached())
        }

        form.create()
        return form
    }



    enum CodingKeys: String, CodingKey {
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

        do {
            try self.decode(from: decoder)  // call base class for defaults.

            let values = try decoder.container(keyedBy: CodingKeys.self)

            self.firstName = try values.decode(String.self, forKey: .firstName)
            self.middleName = try values.decode(String.self, forKey: .middleName)
            self.lastName = try values.decode(String.self, forKey: .lastName)
            self.birthday = try values.decode(Date.self, forKey: .birthday)
            self.subjectTypeId = try values.decode(String.self, forKey: .subjectTypeId)
            self.photoConsent = try values.decode(Bool.self, forKey: .photoConsent)
            self.profilePhoto = try values.decodeIfPresent(String.self, forKey: .profilePhoto)
            self.unitIds = try values.decode(List<String>.self, forKey: .unitIds)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

}


extension RLMSubject: DataProvider {
    typealias T = RLMSubject
}


typealias SubjectsResponse = APIResponse<[RLMSubject]>
