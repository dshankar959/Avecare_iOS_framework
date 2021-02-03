import CocoaLumberjack
import RealmSwift



extension DataProvider where Self: Object {    // +Sync

    static func findAllToSync(detached: Bool = false) -> [Self] {
        let database = getDatabase()

        guard let allObjects = database?.objects(Self.self).filter("rawPublishState = \(PublishState.publishing.rawValue)") else {
            return []
        }

//        DDLogDebug("allObjects[\(Self.description())] = \(allObjects.count)")

        return allObjects.map { return detached ? $0.detached() : $0 }
    }


}
