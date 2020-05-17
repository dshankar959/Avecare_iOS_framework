import RealmSwift



class RLMLogPhotoRow: RLMDefaults {
    // RLMDefaults.id will be used to link with image

    @objc dynamic var title = ""
    @objc dynamic var text: String?

    private enum CodingKeys: String, CodingKey {
        case title
        case text
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        try super.decode(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let title = try container.decodeIfPresent(String.self, forKey: .title) {
            self.title = title
        }
        self.text = try container.decodeIfPresent(String.self, forKey: .text)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(text, forKey: .text)
    }
}

extension RLMLogPhotoRow: DataProvider, RLMCleanable {

    func clean() {
        //TODO: remove local photo

        delete()
    }

}
