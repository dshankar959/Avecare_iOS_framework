import RealmSwift



class RLMOptionValue: Object, Codable {
    @objc dynamic var value = 0
    @objc dynamic var text = ""
}


extension RLMOptionValue: DataProvider {

}
