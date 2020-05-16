import Foundation
import Moya

struct StoryAPIModel {

    let unitId: String
    let title: String
    let body: String
    let publishedAt: Date
    let imageURL: URL?
    let imageName: String

    private enum CodingKeys: String, CodingKey {
        case unitId, title, body, publishedAt, story, files
    }

    init(unitId: String, story: RLMStory, date: Date, storage: ImageStorageService) {
        self.unitId = unitId
        imageName = story.id
        title = story.title
        body = story.body
        publishedAt = date
        imageURL = storage.imageURL(name: story.id)
    }


}

extension StoryAPIModel: MultipartEncodable {
    var formData: [Moya.MultipartFormData] {
        var data = [Moya.MultipartFormData]()
        if let value = title.data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.title.rawValue))
        }
        if let value = body.data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.body.rawValue))
        }
        if let value =  Date.localFormatISO8601StringFromDate(publishedAt).data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.publishedAt.rawValue))
        }
        // FIXME: fill this json when templates ready
        // at this moment we have enough data w/o story json to build RLMStory model
        if let value = "{}".data(using: .utf8) {
            data.append(.init(provider: .data(value), name: CodingKeys.story.rawValue))
        }
        if let url = imageURL {
            data.append(.init(provider: .file(url), name: imageName))
        }
        return data
    }
}