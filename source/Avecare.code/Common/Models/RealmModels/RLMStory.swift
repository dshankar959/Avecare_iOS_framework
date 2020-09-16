import RealmSwift
import CocoaLumberjack



class RLMStory: RLMDefaults, RLMPublishable {

    @objc dynamic var title: String = ""
    @objc dynamic var rawPublishState: Int = PublishState.local.rawValue    // RLMPublishable protocol var(s)
    @objc dynamic var unit: RLMUnit?

    var storyFileURL: String?

    override static func ignoredProperties() -> [String] {
        return ["storyFile"]
    }


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


extension RLMStory {
    /*
        > When we sync down any JSON that contains a url to an image or other binary data from the server,
        > we will need to immediately also sync it down locally.  As the url links from the server are set
        > to expire in ~1 hour from receiving the link.
    */

    func pdfURL(using storage: DocumentService) -> URL? {
        return storage.fileURL(name: id, type: "pdf")
    }

}


extension RLMStory: RLMCleanable, DataProvider {

    func clean() {
        delete()
    }

}


// MARK: - API -

struct PublishedStoriesRequestModel: Codable {

    var unitId: String
    var resultsOffset: Int = 0
    var resultsLimit: Int = 0
    var startDate: String = ""
    var endDate: String = ""
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
