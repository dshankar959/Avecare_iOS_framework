import RealmSwift



class RLMLogPhotoRow: Object, Codable {

    @objc dynamic var id: String = ""   // .id will be used to link with image file
    @objc dynamic var title = ""
    @objc dynamic var text: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case text
    }


    convenience required init(from decoder: Decoder) throws {
        self.init()

        let values = try decoder.container(keyedBy: CodingKeys.self)

        if let id = try values.decodeIfPresent(String.self, forKey: .id)?.lowercased() {
            self.id = id
        } else {
            self.id = newUUID
        }

        if let title = try values.decodeIfPresent(String.self, forKey: .title) {
            self.title = title
        }

        self.text = try values.decodeIfPresent(String.self, forKey: .text)
    }


    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)

        try values.encodeIfPresent(id.lowercased(), forKey: .id)
        try values.encode(title, forKey: .title)
        try values.encodeIfPresent(text, forKey: .text)
    }


    override static func primaryKey() -> String {
        return "id"
    }


    convenience init(id: String) {
        self.init()
        self.id = id
    }

    func prepareForReuse() {
        id = newUUID
    }

}

extension RLMLogPhotoRow: DataProvider, RLMCleanable {

    func clean() {
        //TODO: remove local photo

        delete()
    }

}
