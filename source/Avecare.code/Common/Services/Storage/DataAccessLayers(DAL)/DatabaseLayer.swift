import CocoaLumberjack
import RealmSwift



struct DALConfig {
    static let DatabaseSchemaVersion: UInt64 = 1
    static let realmStoreName: String = "avecare.realm"   // default
    static var userRealmFileURL: URL?
}


// In generic protocols, to create something like <T> in generics, you need to add `associatedtype`.
// https://www.bobthedeveloper.io/blog/generic-protocols-with-associated-type
protocol DatabaseLayer {
//    associatedtype T: Object
}


extension DatabaseLayer where Self: Object {

    // MARK: - DB setup

    private static var userRealmFile: URL {
        if let url = DALConfig.userRealmFileURL {
            return url
        }

        let fullPathURL = userAppDirectory.appendingPathComponent(DALConfig.realmStoreName)
        DALConfig.userRealmFileURL = fullPathURL

        return fullPathURL
    }


    private static var realmConfig: Realm.Configuration {

        var config = Realm.Configuration(
            // Migration Support
            //
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: DALConfig.DatabaseSchemaVersion,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above.
            migrationBlock: { _, oldSchemaVersion in
                // If we haven’t migrated anything yet, then `oldSchemaVersion` == 0
                if oldSchemaVersion < DALConfig.DatabaseSchemaVersion {
                    // Realm will automatically detect new properties and removed properties,
                    // and will update the schema on disk automatically.
                    DDLogVerbose("⚠️  Migrating Realm DB: from v\(oldSchemaVersion) to v\(DALConfig.DatabaseSchemaVersion)  ⚠️")
/*
                    /// version specific migration steps.. if required.
                    if oldSchemaVersion < 2 {
                        DDLogVerbose("⚠️ ++ \"oldSchemaVersion < 2\"  ⚠️")
                        // Changes for v2:
                        // ....
                    }
*/
                }
        })

        config.fileURL = userRealmFile

        config.shouldCompactOnLaunch = { (totalBytes: Int, usedBytes: Int) -> Bool in
            let bcf = ByteCountFormatter()
            bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
            bcf.countStyle = .file

            // Compact if the file is over 100mb in size and less than 60% 'used'
            let filesizeMB = 100 * 1024 * 1024
            let compactRealm: Bool = (totalBytes > filesizeMB) && (Double(usedBytes) / Double(totalBytes)) < 0.6

            if compactRealm {
                DDLogVerbose("Compacting Realm db (\(DALConfig.realmStoreName)? : \(compactRealm ? "[YES]" : "[NO]")")

                // totalBytes refers to the size of the file on disk in bytes (data + free space)
                let totalBytesString = bcf.string(fromByteCount: Int64(totalBytes))
                // usedBytes refers to the number of bytes used by data in the file
                let usedBytesString = bcf.string(fromByteCount: Int64(usedBytes))
                DDLogVerbose("size_of_realm_file: \(totalBytesString), used_bytes: \(usedBytesString)")

                let utilization = Double(usedBytes) / Double(totalBytes) * 100.0
                DDLogVerbose(String(format: "utilization: %.0f%%", utilization))
            }

            return compactRealm
        }

        return config
    }


    static func getDatabase() -> Realm? {
        do {
            let realm = try Realm(configuration: realmConfig)
            realm.autorefresh = true
            return realm
        } catch let error {
            DDLogError("Database error: \(error)")
            fatalError("Database error: \(error)")
        }
    }


    // MARK: - Generic Low-level CRUD

    func create() {
        autoreleasepool {
            do {
                let database = Self.getDatabase()
                try database?.write {
                    database?.add(self)
                }
            } catch let error {
                DDLogError("Database error: \(error)")
                fatalError("Database error: \(error)")
            }
        }
    }

/*
    func create<T: Object>(_ object: T = self as! Object) {
        autoreleasepool {
            do {
                let database = self.getDatabase()
                try database?.write {
                    database?.add(object)
                }
            } catch let error {
                DDLogError("Database error: \(error)")
                fatalError("Database error: \(error)")
            }
        }
    }
*/

    // note: 'primary id' required for this to function.
    static func createOrUpdateAll(with objects: [Self], update: Bool = true) {
        autoreleasepool {
            do {
                let database = getDatabase()
                try database?.write {
                    database?.add(objects, update: update ? .all : .error)
                }
            } catch let error {
                DDLogError("Database error: \(error)")
                fatalError("Database error: \(error)")
            }
        }
    }


    func delete() {
        autoreleasepool {
            do {
                let database = Self.getDatabase()
                try database?.write {
                    database?.delete(self)
                }
            } catch let error {
                DDLogError("Database error: \(error)")
                fatalError("Database error: \(error)")
            }
        }
    }

/*
    func delete<T: Object>(object: T) {
        autoreleasepool {
            do {
                let database = self.getDatabase()
                try database?.write {
                    database?.delete(object)
                }
            } catch let error {
                DDLogError("Database error: \(error)")
                fatalError("Database error: \(error)")
            }
        }
    }
*/

    static func deleteAll(objects: [Self]) {
        autoreleasepool {
            do {
                let database = Self.getDatabase()
                try database?.write {
                    database?.delete(objects)
                }
            } catch let error {
                DDLogError("Database error: \(error)")
                fatalError("Database error: \(error)")
            }
        }
    }


    static func deleteAllOfType(objectType: Object.Type) {
        autoreleasepool {
            do {
                let database = Self.getDatabase()
                try database?.write {
                    if let allObjects = database?.objects(objectType) {
                        database?.delete(allObjects)
                    }
                }
            } catch let error {
                DDLogError("Database error: \(error)")
                fatalError("Database error: \(error)")
            }
        }
    }


    static func writeTransaction(writeTransactionBlock: @escaping () -> Void) {
        autoreleasepool {
            do {
                let database = getDatabase()
                try database?.write {
                    writeTransactionBlock()
                }
            } catch let error {
                DDLogError("Database error: \(error)")
                fatalError("Database error: \(error)")
            }
        }
    }


    // MARK: - Change notifications

    // Setup to observe Realm `CollectionChange` notifications
    func setupNotificationToken(for observer: AnyObject, _ block: @escaping () -> Void) -> NotificationToken? {
        let database = Self.getDatabase()

        return database?.objects(Self.self).observe { [weak observer] (changes: RealmCollectionChange) in
            if observer != nil {
                switch changes {
                case .initial:
                return  // ignore first setup
                case .update:
                    //                case .update(let objects, let deletions, let insertions, let modifications):
                    /// .. a write transaction has been committed which either changed which objects are in the collection,
                    /// and/or modified one or more of the objects in the collection.
                    //                    DDLogDebug("NotificationToken triggered on: \(observer!) for object: \(T.self)")
                    /*
                     DDLogDebug("(triggered!) - objects count = \(objects.count)")
                     for object in objects {
                     if let id = object.value(forKey: "id") as? String {
                     DDLogDebug("id = \(id)")
                     }
                     }

                     DDLogDebug("deletions = \(deletions)")
                     DDLogDebug("insertions = \(insertions)")
                     DDLogDebug("modifications = \(modifications)")
                     */
                    block()
                case .error(let err):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(err)")
                }
            }
        }
    }


    // MARK: -

    // Useful for multithreading purposes.
    // https://stackoverflow.com/a/45810078/7599
    func forceRefresh() {
        Self.getDatabase()?.refresh()
    }

}
