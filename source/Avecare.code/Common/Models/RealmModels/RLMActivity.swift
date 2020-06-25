import RealmSwift
import CocoaLumberjack

class RLMActivity: RLMDefaults, RLMPublishable, DataProvider {

    @objc dynamic var rawPublishState: Int = PublishState.local.rawValue
    @objc dynamic var activityOption: RLMActivityOption?
    @objc dynamic var activityDate: Date?
    @objc dynamic var unit: RLMUnit?
    @objc dynamic var instructions: String?

    enum CodingKeys: String, CodingKey {
        case activityId
        case unitId
        case date
        case instructions
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try super.decode(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let activityOptionId = try container.decode(String.self, forKey: .activityId)
            self.activityOption = RLMActivityOption.find(withID: activityOptionId)

            if let timeString = try container.decodeIfPresent(String.self, forKey: .date),
               let time = Date.dateFromLogFormString(timeString) {
                activityDate = time
            }

            let unitId = try container.decode(String.self, forKey: .unitId)
            self.unit = RLMUnit.find(withID: unitId)

            self.instructions = try container.decode(String?.self, forKey: .instructions)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    override func encode(to encoder: Encoder) throws {
        do {
            try super.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(activityOption?.id, forKey: .activityId)
            try container.encode(unit?.id, forKey: .unitId)
            if let instructions = instructions {
                if !instructions.isEmpty {
                    try container.encode(instructions, forKey: .instructions)
                }
            }
            try container.encode(Date.yearMonthDayFormatter.string(from: activityDate ?? Date()), forKey: .date)

        } catch {
            DDLogError("JSON Encoding error = \(error)")
            fatalError("JSON Encoding error = \(error)")
        }

    }
}

typealias RLMActivityResponse = RLMActivity
