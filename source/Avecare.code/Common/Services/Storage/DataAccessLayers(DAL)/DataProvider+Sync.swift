import CocoaLumberjack
import RealmSwift



extension DataProvider where Self: Object {    // +Sync

    static func findAllToSync() -> [Self] {
        let database = getDatabase()

        guard let allObjects = database?.objects(Self.self).filter("rawPublishState = \(PublishState.publishing.rawValue)") else {
            return []
        }

        return allObjects.map { $0 }
    }


}
