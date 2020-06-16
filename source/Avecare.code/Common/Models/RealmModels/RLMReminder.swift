import RealmSwift
import CocoaLumberjack

class RLMReminder: RLMDefaults, RLMPublishable {

    @objc dynamic var subject: RLMSubject?
    @objc dynamic var rawPublishState: Int = PublishState.local.rawValue
    @objc dynamic var message: String?
    @objc dynamic var reminderOption: RLMReminderOption?

    private enum CodingKeys: String, CodingKey {
        case title
        case storyFile
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        do {
            try super.decode(from: decoder)

            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.title = try container.decode(String.self, forKey: .title)
            self.storyFileURL = try container.decodeIfPresent(String.self, forKey: .storyFile)
        } catch {
            DDLogError("JSON Decoding error = \(error)")
            fatalError("JSON Decoding error = \(error)")
        }
    }

    override func encode(to encoder: Encoder) throws {
        do {
            try super.encode(to: encoder)

            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
        } catch {
            DDLogError("JSON Encoding error = \(error)")
            fatalError("JSON Encoding error = \(error)")
        }

    }
}


extension RLMReminder {

    func pdfURL(using storage: DocumentService) -> URL? {
        return storage.fileURL(name: id, type: "pdf")
    }

}


extension RLMReminder: RLMCleanable, DataProvider {

    func clean() {
        delete()
    }

}


// MARK: - API -

struct PublishedReminderRequestModel: Codable {

    let unitId: String
    let resultsOffset: Int = 0
    let resultsLimit: Int = 15
    let startDate: String = ""
    let endDate: String = ""
    var serverLastUpdated: String = ""


    init(id: String) {
        self.unitId = id

        let allStories = RLMStory.findAll()
        let sortedStories = RLMStory.sortObjectsByLastUpdated(order: .orderedDescending, allStories)
        let publishedStories = sortedStories.filter { $0.rawPublishState == PublishState.published.rawValue }

        if let lastUpdated = publishedStories.first?.serverLastUpdated {
            serverLastUpdated = Date.ISO8601StringFromDate(lastUpdated)
        }
    }

}
