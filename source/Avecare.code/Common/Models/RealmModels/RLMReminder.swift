import RealmSwift
import CocoaLumberjack

class RLMReminder: RLMDefaults, RLMPublishable, DataProvider {

    @objc dynamic var subject: RLMSubject?
    @objc dynamic var rawPublishState: Int = PublishState.local.rawValue
    @objc dynamic var message: String?
    @objc dynamic var reminderOption: RLMReminderOption?

    enum CodingKeys: String, CodingKey {
        case id
        case reminderId
        case subjectId
        case details
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try super.decode(from: decoder)

            let container = try decoder.container(keyedBy: CodingKeys.self)

            let subId = try container.decode(String.self, forKey: .subjectId)
            self.subject = RLMSubject.find(withID: subId)

            let remOptionId = try container.decode(String.self, forKey: .reminderId)
            self.reminderOption = RLMReminderOption.find(withID: remOptionId)
            self.message = try container.decode(String?.self, forKey: .details)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    override func encode(to encoder: Encoder) throws {
        do {
            try super.encode(to: encoder)

            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(reminderOption?.id, forKey: .reminderId)
            try container.encode(subject?.id, forKey: .subjectId)
            if let message = message {
                if !message.isEmpty {
                    try container.encode(message, forKey: .details)
                }
            }
        } catch {
            DDLogError("JSON Encoding error = \(error)")
            fatalError("JSON Encoding error = \(error)")
        }

    }
}

typealias RLMReminderResponse = RLMReminder
