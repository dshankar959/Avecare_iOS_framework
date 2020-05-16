import Foundation
import RealmSwift



class RLMLogPhotoRow: Object, Decodable {
    @objc dynamic var imageUrl: String?
    @objc dynamic var title = ""
    @objc dynamic var text: String?

}


extension RLMLogPhotoRow: DataProvider, RLMCleanable {
    typealias T = RLMLogPhotoRow

    func clean() {
        //TODO: remove local photo

        delete()
    }
}
