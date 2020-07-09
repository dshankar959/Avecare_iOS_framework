import RealmSwift



class RLMLogTagsRow: Object, Decodable, FormRowIconProtocol {

    enum CodingKeys: String, CodingKey {
        case title
        case placeholder
        case selectedValues
        case options
    }

    @objc dynamic var iconName = ""
    @objc dynamic var iconColor: Int32 = 0

    @objc dynamic var title = ""
    @objc dynamic var placeholder = ""
    var selectedValues = List<Int>()
    let options = List<RLMOptionValue>()

    required convenience init(from decoder: Decoder) throws {
        self.init()
        try decodeIcon(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        placeholder = try container.decode(String.self, forKey: .placeholder)
        if let selectedValues = try container.decodeIfPresent([Int].self, forKey: .selectedValues) {
            self.selectedValues.append(objectsIn: selectedValues)
        }
        if let options = try container.decodeIfPresent([RLMOptionValue].self, forKey: .options) {
            self.options.append(objectsIn: options)
        }
    }
}


extension RLMLogTagsRow: Encodable {

    func encode(to encoder: Encoder) throws {
        try encodeIcon(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encode(placeholder, forKey: .placeholder)
        try container.encode(selectedValues, forKey: .selectedValues)

        var optionsContainer = container.nestedUnkeyedContainer(forKey: .options)
        for option in options {
            try optionsContainer.encode(option)
        }
    }

}


extension RLMLogTagsRow: DataProvider, RLMCleanable {

    func clean() {
        RLMOptionValue.deleteAll(objects: Array(options))
        delete()
    }

}