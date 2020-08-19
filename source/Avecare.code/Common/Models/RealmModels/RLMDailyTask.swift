import RealmSwift
import CocoaLumberjack



class RLMDailyTask: Object, Codable, DataProvider {

    @objc dynamic var dailyTaskOption: RLMDailyTaskOption?
    @objc dynamic var completed: Bool = false

    enum CodingKeys: String, CodingKey {
        case id
        case completed
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let dailyTaskOptionId = try container.decode(String.self, forKey: .id)
            self.dailyTaskOption = RLMDailyTaskOption.find(withID: dailyTaskOptionId)
            self.completed = try container.decode(Bool.self, forKey: .completed)

        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(dailyTaskOption?.id, forKey: .id)
            try container.encode(completed, forKey: .completed)
        } catch {
            DDLogError("JSON Encoding error = \(error)")
            fatalError("JSON Encoding error = \(error)")
        }
    }
}



extension RLMDailyTask: RLMCleanable {

    func clean() {
        dailyTaskOption?.delete()
        delete()
    }

}
