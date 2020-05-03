import Foundation

struct DynamicCodingKey: CodingKey {
    enum Errors: Error {
        case canNotCreateDynamicKey
    }

    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }

    init?(intValue: Int) {
        self.intValue = intValue
        stringValue = "\(intValue)"
    }

    static func key(named name: String) throws -> DynamicCodingKey {
        guard let key = DynamicCodingKey(stringValue: name) else {
            throw Errors.canNotCreateDynamicKey
        }
        return key
    }
}
