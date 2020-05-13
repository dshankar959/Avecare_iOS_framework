import CocoaLumberjack
import RealmSwift



protocol DataProvider: DatabaseLayer {
}


extension DataProvider {
    // MARK: - Generic `model` specific operations

    func find(withID: String) -> T? {
        let database = self.getDatabase()
        return database?.object(ofType: T.self, forPrimaryKey: withID)
    }


    func findAll() -> [T] {
        if let database = self.getDatabase() {
            return database.objects(T.self).map { $0 }
        } else {
            return []
        }
    }


    func findAll<T: Object>(sortedBy key: String) -> [T] {
        let database = self.getDatabase()

        if let allObjects = database?.objects(T.self) {
            let results = allObjects.sorted(byKeyPath: key, ascending: true)
            return Array(results)
        }

        return []
    }

    func find(withSubjectID: String) -> T? {
        let database = self.getDatabase()
        return database?.objects(T.self).filter("subject.id = %@", withSubjectID).first
    }


    func findAllWith(_ withIDs: [String]) -> [T] {
        if withIDs.isEmpty {
            return []
        }

        let database = self.getDatabase()

        if let allObjects = database?.objects(T.self) {
            let results = allObjects.filter("id IN %@", withIDs)
            return Array(results)
        } else {
            return []
        }

    }


/*
    func find<T: Object>(withName: String) -> T? {
        let database = self.getDatabase()
        return database?.objects(T.self).filter("name = '\(withName)'").first
    }

    func find(withEmail: String) -> T? {
        let database = self.getDatabase()
        // Realm case insensitive search syntax
        // https://stackoverflow.com/a/43746523/7599
        return database?.objects(T.self).filter("email contains[c] %@", withEmail).first
    }

    func findAllWith(_ withIDs: [String]) -> [T] {

        if withIDs.isEmpty {
            return []
        }

        var predicateFormat: String = ""

        if withIDs.count != 0 {
            for (index, id) in withIDs.enumerated() {
                predicateFormat += "id = '\(id)'"
                if index != withIDs.count-1 {
                    predicateFormat += " || "
                }
            }
        }

        return filterAllwithPredicate(predicateFormat)
    }

    func findAllWith(_ orgID: String,
                     locationID: String = "",
                     projectIDs: [String] = [],
                     workflowStateIDs: [String] = [],
                     reviewStates: [String] = [],
                     signTypeIDs: [String] = [],
                     signIDs: [String] = [],
                     sortedByOrderID: Bool = false,
                     withAdditionalPredicate: String = "") -> [T] {

        var predicateFormat: String = "organizationID = '\(orgID)'"

        if !locationID.isEmpty {
            predicateFormat += " && locationID = '\(locationID)'"
        }

        if projectIDs.count != 0 {
            predicateFormat += " && ("
            for (index, id) in projectIDs.enumerated() {
                predicateFormat += "projectID = '\(id)'"
                if index != projectIDs.count-1 {
                    predicateFormat += " || "
                }
            }
            predicateFormat += ")"
        }

        if workflowStateIDs.count != 0 {
            predicateFormat += " && ("
            for (index, id) in workflowStateIDs.enumerated() {
                predicateFormat += "workflowStateID = '\(id)'"
                if index != workflowStateIDs.count-1 {
                    predicateFormat += " || "
                }
            }
            predicateFormat += ")"
        }

        if signTypeIDs.count != 0 {
            predicateFormat += " && ("
            for (index, id) in signTypeIDs.enumerated() {
                predicateFormat += "signTypeID = '\(id)'"
                if index != signTypeIDs.count-1 {
                    predicateFormat += " || "
                }
            }
            predicateFormat += ")"
        }

        if signIDs.count != 0 {
            predicateFormat += " && ("
            for (index, id) in signIDs.enumerated() {
                predicateFormat += "signID = '\(id)'"
                if index != signIDs.count-1 {
                    predicateFormat += " || "
                }
            }
            predicateFormat += ")"
        }

        if reviewStates.count != 0 {
            predicateFormat += " && ("
            for (index, id) in reviewStates.enumerated() {
                predicateFormat += "reviewState = '\(id)'"
                if index != reviewStates.count-1 {
                    predicateFormat += " || "
                }
            }
            predicateFormat += ")"
        }

        if !withAdditionalPredicate.isEmpty {
            predicateFormat += " && \(withAdditionalPredicate)"
        }

        return filterAllwithPredicate(predicateFormat, sortedByOrderID: sortedByOrderID)
    }

    private func filterAllwithPredicate(_ predicateFormat: String, sortedByOrderID: Bool = true) -> [T] {
//        DDLogInfo("\(predicateFormat)")
        let database = self.getDatabase()

        if let allObjects = database?.objects(T.self) {
            if sortedByOrderID {
                let results = allObjects.sorted(byKeyPath: "orderID", ascending: true).filter(predicateFormat)
                return Array(results)
            } else {
                let results = allObjects.filter(predicateFormat)
                return Array(results)
            }
        }

        return []
    }

    // MARK: -

    func updateRemovedOnClientFlag(for id: String, with state: Bool) {
        updateObject(id, forKey: "isRemovedOnClient", with: state)
    }

    // MARK: -

    func updateObject(_ id: String, forKey: String, with value: String) {   // update with `String` value
        let database = self.getDatabase()!
        let object = database.object(ofType: T.self, forPrimaryKey: id)!

        do {
            try database.write {
                object.setValue(value, forKey: forKey)
            }
        } catch let error {
            DDLogError("Database error: \(error)")
            fatalError("Database error: \(error)")
        }
    }

    func updateObject(_ id: String, forKey: String, with value: Bool) {   // update with `Bool` value
        let database = self.getDatabase()!
        let object = database.object(ofType: T.self, forPrimaryKey: id)!

        do {
            try database.write {
                object.setValue(value, forKey: forKey)
            }
        } catch let error {
            DDLogError("Database error: \(error)")
            fatalError("Database error: \(error)")
        }
    }

    func getAllSortedByName() -> [T] {
        return findAll(sortedBy: "name")
    }

/*
    // sorted by "******LastUpdated"
    func sortObjectsByLastUpdated<T: RLMDefaults>(_ objects: [T]) -> [T] {

        if objects.isEmpty {
            return []
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.dateFormat = DALconfig.ISO8601dateFormat

        let sortedObjects = objects.sorted(by: {
            // Convert ISO8601 date string format to Date() object.
            let serverDate0: Date? = $0.serverLastUpdated != nil ? formatter.date(from: $0.serverLastUpdated!) : nil
            let serverDate1: Date? = $1.serverLastUpdated != nil ? formatter.date(from: $1.serverLastUpdated!) : nil
            let clientDate0: Date? = $0.clientLastUpdated != nil ? formatter.date(from: $0.clientLastUpdated!) : nil
            let clientDate1: Date? = $1.clientLastUpdated != nil ? formatter.date(from: $1.clientLastUpdated!) : nil

            // Filter and sort each object separately.
            let objDate0: Date? = self.filterOptionalsWithLargeNil(lhs: serverDate0, rhs: clientDate0)
            let objDate1: Date? = self.filterOptionalsWithLargeNil(lhs: serverDate1, rhs: clientDate1)

            // Final comparison.
            guard let finalDate0 = objDate0 else { return false }
            guard let finalDate1 = objDate1 else { return false }

            return finalDate0.compare(finalDate1) == .orderedDescending

        })

        return sortedObjects
    }

    // fyi ref: @Martin R, https://stackoverflow.com/a/53427282/7599
    private func filterOptionalsWithLargeNil<T: Comparable>(lhs: T?, rhs: T?) -> T? {
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
*/
*/
}
