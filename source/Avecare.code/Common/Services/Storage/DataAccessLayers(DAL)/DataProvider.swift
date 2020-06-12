import CocoaLumberjack
import RealmSwift


protocol DataProvider: DatabaseLayer {

}

extension DataProvider where Self: Object {
    // MARK: - Generic `model` specific operations

    static func find(withID: String) -> Self? {
        let database = getDatabase()
        return database?.object(ofType: Self.self, forPrimaryKey: withID)
    }


    static func findAll() -> [Self] {
        if let database = getDatabase() {
            return database.objects(Self.self).map {
                $0
            }
        } else {
            return []
        }
    }


    static func findAll(sortedBy key: String) -> [Self] {
        let database = getDatabase()

        if let allObjects = database?.objects(Self.self) {
            let results = allObjects.sorted(byKeyPath: key, ascending: true)
            return Array(results)
        }

        return []
    }


    static func find(withSubjectID: String) -> Self? {
        let database = getDatabase()
        return database?.objects(Self.self).filter("subject.id = %@", withSubjectID).first
    }


    static func findAll(withSubjectID: String) -> [Self] {
        let database = getDatabase()

        if let allObjects = database?.objects(Self.self) {
            let results = allObjects.filter("subject.id = %@", withSubjectID)
            return Array(results)
        }

        return []
    }

    static func findAllWith(_ withIDs: [String]) -> [Self] {
        if withIDs.isEmpty {
            return []
        }

        let database = getDatabase()

        if let allObjects = database?.objects(Self.self) {
            let results = allObjects.filter("id IN %@", withIDs)
            return Array(results)
        } else {
            return []
        }

    }

    // sorted by "******LastUpdated"
    static func sortObjectsByLastUpdated<T: RLMDefaults>(order: ComparisonResult, _ objects: [T]) -> [T] {
        if objects.isEmpty {
            return []
        }

        let sortedObjects = objects.sorted(by: {
            // Filter and sort each object separately.
            let objDate0: Date? = filterOptionalsWithLargeNil(lhs: $0.serverLastUpdated, rhs: $0.clientLastUpdated)
            let objDate1: Date? = filterOptionalsWithLargeNil(lhs: $1.serverLastUpdated, rhs: $1.clientLastUpdated)

            // Final comparison.
            guard let finalDate0 = objDate0 else { return false }
            guard let finalDate1 = objDate1 else { return false }

            return finalDate0.compare(finalDate1) == order
        })

        return sortedObjects
    }

    // fyi ref: @Martin R, https://stackoverflow.com/a/53427282/7599
    private static func filterOptionalsWithLargeNil<T: Comparable>(lhs: T?, rhs: T?) -> T? {
        var result: T?

        switch (lhs, rhs) {
        case let(l?, r?): result = l > r ? l : r    // Both lhs and rhs are not nil
        case let(nil, r?): result = r               // Lhs is nil
        case let(l?, nil): result = l               // Lhs is not nil, rhs is nil
        case (.none, .none):
            result = nil
        }

        return result
    }


}
