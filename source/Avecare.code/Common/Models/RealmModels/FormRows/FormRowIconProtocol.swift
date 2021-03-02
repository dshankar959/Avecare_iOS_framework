import Foundation



protocol FormRowIconProtocol: class {
    var iconName: String { get set }
    var iconColor: Int32 { get set }
}


private enum  FormRowIconKeys: String, CodingKey {
    case iconName
    case iconColor
}


extension FormRowIconProtocol {

    func decodeIcon(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FormRowIconKeys.self)

        if let value = try container.decodeIfPresent(String.self, forKey: .iconName) {
            iconName = value
        }

        if let str = try container.decodeIfPresent(String.self, forKey: .iconColor),
           let value = Int32(str, radix: 16) {
            iconColor =  value
        }
    }

    func encodeIcon(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FormRowIconKeys.self)

        try container.encode(iconName, forKey: .iconName)
        let colorHexString = String(format: "%06X", iconColor)
        try container.encode(colorHexString, forKey: .iconColor)
    }

}