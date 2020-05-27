import Foundation
import RealmSwift



class RLMStory: RLMDefaults, RLMPublishable {

    @objc dynamic var title: String = ""
    @objc dynamic var rawPublishState: Int = PublishState.local.rawValue    // RLMPublishable protocol var(s)
    @objc dynamic var body: String = ""
    @objc dynamic var photoCaption: String = ""     // local image files match via @id
    @objc dynamic var unit: RLMUnit?


    private enum CodingKeys: String, CodingKey {
        case title
        case body
        case photoCaption
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try super.decode(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)

        self.body = try container.decode(String.self, forKey: .body)
        self.photoCaption = try container.decode(String.self, forKey: .photoCaption)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(photoCaption, forKey: .photoCaption)

    }
}

extension RLMStory {
    /*
        > When we sync down any JSON that contains a url to an image or other binary data from the server,
        > we will need to immediately also sync it down locally.  As the url links from the server are set
        > to expire in ~1 hour from receiving the link.
    */
    func photoURL(using storage: ImageStorageService) -> URL? {
        return storage.imageURL(name: id)
    }
}

extension RLMStory: RLMCleanable, DataProvider {
    func clean() {

    }
}
