import RealmSwift
import CocoaLumberjack



class RLMLogSwitcherRow: Object, Decodable, FormRowIconProtocol {

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case startTime
        case endTime
        case selectedValue
        case options
    }

    @objc dynamic var iconName = ""
    @objc dynamic var iconColor: Int32 = 0

    @objc dynamic var title = ""
    @objc dynamic var subtitle = ""
    @objc dynamic var startTime = Date()
    @objc dynamic var endTime = Date(timeIntervalSinceNow: 30 * 60)

    @objc dynamic var selectedValue: Int = 0
    let options = List<RLMOptionValue>()

    required convenience init(from decoder: Decoder) throws {
        self.init()
        try decodeIcon(from: decoder)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)

        let formatter = Date.timeFormatter
        if let timeString = try container.decodeIfPresent(String.self, forKey: .startTime),
           let time = formatter.date(from: timeString) {
            startTime = time
        }
        if let timeString = try container.decodeIfPresent(String.self, forKey: .endTime),
           let time = formatter.date(from: timeString) {
            endTime = time
        }

        if let options = try container.decodeIfPresent([RLMOptionValue].self, forKey: .options) {
            self.options.append(objectsIn: options)
        }
        if let value = try container.decodeIfPresent(Int.self, forKey: .selectedValue) {
            selectedValue = value
        } else if let value = options.first?.value {
            selectedValue = value
        } else {
            DDLogError("JSON Decoding error: No selected value")
        }

    }
}

extension RLMLogSwitcherRow: Encodable {
    func encode(to encoder: Encoder) throws {
        try encodeIcon(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        let formatter = Date.timeFormatter
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(formatter.string(from: startTime), forKey: .startTime)
        try container.encode(formatter.string(from: endTime), forKey: .endTime)
        try container.encodeIfPresent(selectedValue, forKey: .selectedValue)

        var optionsContainer = container.nestedUnkeyedContainer(forKey: .options)
        for option in options {
            try optionsContainer.encode(option)
        }
    }
}

extension RLMLogSwitcherRow: DataProvider, RLMCleanable {
    func clean() {
        RLMOptionValue.deleteAll(objects: Array(options))
        delete()
    }
}
