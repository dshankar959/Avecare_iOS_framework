import Moya
import CocoaLumberjack



struct PublishStoryRequestModel {

    let unitId: String
    let story: RLMStory
    let storage: DocumentService

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case storyFile
    }

    init(unitId: String, story: RLMStory, storage: DocumentService) {
        self.story = story
        self.unitId = unitId
        self.storage = storage
    }
}


extension PublishStoryRequestModel: MultipartEncodable {

    var formData: [Moya.MultipartFormData] {
        var data = [Moya.MultipartFormData]()

        if let value = story.id.data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.id.rawValue))
        }

        if let value = story.title.data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.title.rawValue))
        }

        if let url = story.pdfURL(using: storage) { // filename is the same as the object 'id'
            data.append(.init(provider: .file(url), name: CodingKeys.storyFile.rawValue))
        }

        return data
    }

}
