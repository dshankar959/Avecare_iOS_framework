import RealmSwift
import CocoaLumberjack

class RLMInjury: RLMDefaults, RLMPublishable, DataProvider {

    @objc dynamic var subject: RLMSubject?
    @objc dynamic var rawPublishState: Int = PublishState.local.rawValue
     @objc dynamic var message: String?
    @objc dynamic var injuryOption: RLMInjuryOption?
    @objc dynamic var timeOfInjury: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case injuryId
        case timeOfInjury
        case subjectId
        case details
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try super.decode(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let subId = try container.decode(String.self, forKey: .subjectId)
            self.message = try container.decode(String?.self, forKey: .details)
            self.subject = RLMSubject.find(withID: subId)

            let injuryId = try container.decode(String.self, forKey: .injuryId)
            self.injuryOption = RLMInjuryOption.find(withID: injuryId)
            if let timeString = try container.decodeIfPresent(String.self, forKey: .timeOfInjury),
               let time = Date.dateFromISO8601String(timeString) {
                timeOfInjury = time
            }

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    override func encode(to encoder: Encoder) throws {
        do {
            try super.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(injuryOption?.id, forKey: .injuryId)
            try container.encode(subject?.id, forKey: .subjectId)
            try container.encode(Date.ISO8601StringFromDate(timeOfInjury ?? Date()), forKey: .timeOfInjury)

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
