import Foundation
import RealmSwift


class RLMStory: RLMDefaults {

    @objc dynamic var title: String = ""
    @objc dynamic var localDate = Date() // last change date, iso8601
    @objc dynamic var serverDate: Date? // submit date iso8601
    @objc dynamic var body: String = ""
    // access local photo via @id
    @objc dynamic var photoCaption: String = ""
    @objc dynamic var remoteImageURL: String?

    private enum CodingKeys: String, CodingKey {
        case title, localDate, serverDate, body, photoCaption
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try super.decode(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
    }
}

extension RLMStory {
    func photoURL(using storage: ImageStorageService) -> URL? {
        if let remote = remoteImageURL, let url = URL(string: remote) {
            return url
        } else {
            return storage.imageURL(name: id)
        }
    }
}

extension RLMStory: RLMCleanable, DataProvider {
    func clean() {

    }
}
