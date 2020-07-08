import Foundation
import CocoaLumberjack



struct SyncConfig {
    static let timerInterval: TimeInterval = 5*60 // every 5 min.
}

enum SyncState {
    case syncing
    case complete
    case unknown
}

extension Notification.Name {
    static let syncStateChanged = Notification.Name("syncStateChanged")
    static let didCompleteSync = Notification.Name("didCompleteSync")
}


// MARK: -
class SyncEngine {

    var syncTimer: Timer? = nil

    // Array of collected closures to call when sync is complete due to multiple triggers.
    var closuresToPerformWhenSyncComplete: [(_ error: AppError?) -> Void] = []

//    var syncOperationsBlock: ((_ error: AppError?) -> Void)

//    var centralManagerDidUpdateState: ((_ state: Bool) -> Void) = {_ in
//    }


    var syncStates: [String: SyncState] = [:]

    var isSyncing: Bool {
        var state: Bool = false

        for (_, value) in syncStates where value == .syncing {
            state = true
            break
        }

//        DDLogDebug("⭐ isSyncing = \(state)")
        return state
    }


    func print_isSyncingStatus_description() {
        for (key, value) in syncStates {
            DDLogDebug("⭐ \(key) = \(value)")
        }
    }


    var isSyncBlocked: Bool {    // 'read-only' property
        if !isDataConnection {
            DDLogVerbose(" ⚠️  No Data Connection. 📵 Sync disabled.  ⚠️")
            return true
        }

        if isSyncCancelled {
            DDLogVerbose(" ⚠️  Sync cancelled.  ⚠️")
            return true
        }

        return false
    }


    var isSyncCancelled: Bool = false {
        didSet {
            if isSyncCancelled {
                DDLogVerbose(" ⚠️  Sync cancelled.  ⚠️")
            } else {
                DDLogVerbose(" 🆗   Sync resumed.   🆗")
            }
        }
    }


    let syncOperationsQueue: OperationQueue = {
        let q = OperationQueue()
        q.name = "syncOperationsQueue"
        q.maxConcurrentOperationCount = 1

        return q
    }()


    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didCompleteSyncAll), name: .didCompleteSync, object: SyncEngine.self)
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
        DDLogWarn("\(self)")
    }


}



// MARK: -
extension SyncEngine {

    func syncAll(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogVerbose("")

        if !appSettings.enableSyncUp && !appSettings.enableSyncDown {
            DDLogDebug("🔺🔻❌ sync UP/DOWN ⬆️⬇️ disabled.  ❎❎")
            syncCompletion(nil)
            return
        }

        if self.isSyncBlocked {
//            syncCompletion(isSyncCancelled ? nil : NetworkError.NetworkConnectionLost.message)
            syncCompletion(nil)
            return
        }

        if !appSession.isSignedIn() || appSession.token.isFake {
            DDLogError("⚠️ Auth required.")
//            appDelegate.autoSignIn() { error in
//                if error != nil {
//                    syncCompletion(AuthError.expiredSession.message)
//                }
//            }
            return
        }

        if isSyncing {
            DDLogDebug("❕  syncAll =🔄= .syncing  ❕")
            closuresToPerformWhenSyncComplete.append { error in
                syncCompletion(error)
            }
            return
        }

        UIApplication.shared.isIdleTimerDisabled = true
        resetSyncTimer()

        closuresToPerformWhenSyncComplete.append { error in
            syncCompletion(error)
        }

        self.syncOperations() { error in
            DDLogDebug("⭕️ syncOperations ⬇️ complete!  ✅✅")

            for completion in self.closuresToPerformWhenSyncComplete {
                completion(error)
            }

            self.closuresToPerformWhenSyncComplete.removeAll()
            NotificationCenter.default.post(name: .didCompleteSync, object: SyncEngine.self)
        }

    }


    @objc func didCompleteSyncAll(notification: NSNotification) {
        if !syncEngine.isSyncing {
            DDLogVerbose("‼️ sync all complete!")
        }
        UIApplication.shared.isIdleTimerDisabled = false
    }


    func notifySyncStateChanged(message: String) {
        DDLogDebug("\(message)")
        NotificationCenter.default.post(name: .syncStateChanged, object: SyncEngine.self, userInfo: ["message": message])
    }


}
