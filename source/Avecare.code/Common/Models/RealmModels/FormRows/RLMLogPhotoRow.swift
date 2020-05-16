import Foundation
import RealmSwift

class RLMLogPhotoRow: Object, Codable {
    // used to link with local image or with image from API response
    @objc dynamic var filename: String = newUUID
    @objc dynamic var remoteImageURL: String?
    @objc dynamic var title = ""
    @objc dynamic var text: String?

    private enum CodingKeys: String, CodingKey {
        case filename
        case remoteImageURL
        case title
        case text
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let filename = try container.decodeIfPresent(String.self, forKey: .filename) {
            self.filename = filename
        }
        if let title = try container.decodeIfPresent(String.self, forKey: .title) {
            self.title = title
        }
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
        self.remoteImageURL = try container.decodeIfPresent(String.self, forKey: .remoteImageURL)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(filename, forKey: .filename)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(remoteImageURL, forKey: .remoteImageURL)
        try container.encodeIfPresent(text, forKey: .text)
    }
}

extension RLMLogPhotoRow {
    func prepareForReuse() {
        filename = newUUID
    }
}

extension RLMLogPhotoRow: DataProvider, RLMCleanable {


    func clean() {
        //TODO: remove local photo

        delete()
    }
}
