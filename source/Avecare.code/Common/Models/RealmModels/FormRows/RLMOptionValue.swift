import Foundation
import RealmSwift

class RLMOptionValue: Object, Decodable {
    @objc dynamic var value = 0
    @objc dynamic var text = ""
}


extension RLMOptionValue: DataProvider {
    typealias T = RLMOptionValue
}
