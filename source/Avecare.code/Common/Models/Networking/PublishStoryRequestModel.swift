import Foundation
import Moya
import CocoaLumberjack


struct PublishStoryRequestModel {

    let unitId: String
    let story: RLMStory
    let storage: ImageStorageService

    private enum CodingKeys: String, CodingKey {
        case id, story
    }

    init(unitId: String, story: RLMStory, storage: ImageStorageService) {
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
        do {
            let value = try JSONEncoder().encode(story)
            data.append(.init(provider: .data(value), name: CodingKeys.story.rawValue))
        } catch {
            DDLogError("\(error)")
        }

        if let url = story.photoURL(using: storage) {
            data.append(.init(provider: .file(url), name: story.id))
        }
        return data
    }
}

struct PublishStoryResponseModel: Decodable {
    let id: String
    let unitId: String
    let thumbnails: String?
    let files: [FilesResponseModel.File]
    let story: RLMStory
}
