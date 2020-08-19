import RealmSwift
import CocoaLumberjack



class RLMDailyTaskForm: RLMDefaults, RLMPublishable, DataProvider {

    @objc dynamic var rawPublishState: Int = PublishState.local.rawValue
    var tasks = List<RLMDailyTask>()

    enum CodingKeys: String, CodingKey {
        case date
        case tasks
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try super.decode(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if let timeString = try container.decodeIfPresent(String.self, forKey: .date),
               let time = Date.dateFromLogFormString(timeString) {
                self.serverLastUpdated = time
            }

            self.tasks = try container.decode(List<RLMDailyTask>.self, forKey: .tasks)
        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    override func encode(to encoder: Encoder) throws {
        do {
            try super.encode(to: encoder)
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(Date.yearMonthDayFormatter.string(from: clientLastUpdated ?? Date()), forKey: .date)
            // tasks
            var tasksContainer = container.nestedUnkeyedContainer(forKey: .tasks)
            for task in self.tasks {
                try tasksContainer.encode(task)
            }
        } catch {
            DDLogError("JSON Encoding error = \(error)")
            fatalError("JSON Encoding error = \(error)")
        }
    }
}



extension RLMDailyTaskForm: RLMCleanable {

    func clean() {
        tasks.forEach({ $0.clean() })
        delete()
    }

}
