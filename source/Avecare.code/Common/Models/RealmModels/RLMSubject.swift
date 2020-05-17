import CocoaLumberjack
import RealmSwift



class RLMSubject: RLMDefaults {

    @objc dynamic var firstName: String = ""
    @objc dynamic var middleName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var birthday = Date()
    @objc dynamic var subjectTypeId: String = ""
    @objc dynamic var photoConsent: Bool = true

    var unitIds = List<String>()

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

        DDLogVerbose("Today's date = \(Date())")
        DDLogVerbose("Today's date = \(Date.ISO8601StringFromDate(Date()))")
        DDLogVerbose("Today's date = \(Date.local24hrFormatISO8601StringFromDate(Date()))")


        DDLogVerbose("mostRecentLogForm date = \(mostRecentLogForm.clientLastUpdated)")


        let dateTimeString = "2020-05-17T00:01:59.486Z"
        let myDateTime = Date.dateFromISO8601String(dateTimeString)

        let calendar = Calendar.current
        DDLogVerbose("myDateTime.isDateInToday = \(calendar.isDateInToday(myDateTime!))")

//        Calendar.current.isDateInToday(mostRecentLogForm.clientLastUpdated)
//        if let mostRecentLogForm = sortedLogForms.last, Calendar.current.isDateInToday(mostRecentLogForm.clientLastUpdated) {
//            return mostRecentLogForm
//        }



        if let form = logForms.last,
            Calendar.current.isDateInToday(form.clientLastUpdated) {

            DDLogVerbose("logForms.last date = \(form.clientLastUpdated)")
            DDLogVerbose("Calendar.current.isDateInToday = \(Calendar.current.isDateInToday(form.clientLastUpdated))")

            DDLogVerbose(" - ")
        }

*/

        if let form = logForms.sorted(byKeyPath: RLMLogForm.CodingKeys.clientLastUpdated.rawValue, ascending: false).first,
           Calendar.current.isDateInToday(form.clientLastUpdated) {
            return form
        }

        DDLogDebug("Creating today's form for subject: [\(id)], \(firstName) \(lastName) ")
        let form = RLMLogForm()
        form.subject = self

        if let template = RLMFormTemplate.find(withSubjectType: subjectTypeId) {
            DDLogDebug("Loading template: \(template.id)")
            let rows = template.rows.detached()
            rows.forEach({ $0.prepareForReuse() })
            form.rows.append(objectsIn: rows)
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

            let birthDayString: String = try values.decode(String.self, forKey: .birthday)
            guard let birthday = Date.ymdFormatter.date(from: birthDayString) else {
                fatalError("JSON Decoding error = 'Invalid birthday format'")
            }
            self.birthday =  birthday

            self.subjectTypeId = try values.decode(String.self, forKey: .subjectTypeId)
            self.photoConsent = try values.decode(Bool.self, forKey: .photoConsent)

            // load and save image during json response decoding synchronously
            // TODO: some image loading task
            if let profilePhoto = try values.decodeIfPresent(String.self, forKey: .profilePhoto),
               let url = URL(string: profilePhoto) {
                _ = try ImageStorageService().saveImage(url, name: id)
            }

            self.unitIds = try values.decode(List<String>.self, forKey: .unitIds)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

}

extension RLMSubject {
    func photoURL(using storage: ImageStorageService) -> URL? {
        return storage.imageURL(name: id)
    }
}

extension RLMSubject: DataProvider {

}


typealias SubjectsResponse = APIResponse<[RLMSubject]>
