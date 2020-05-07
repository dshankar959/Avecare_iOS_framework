import Foundation
import CocoaLumberjack



struct SyncConfig {
    static let timerInterval: TimeInterval = 3600 // seconds
}

enum SyncStatus {
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

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.dateFormat = DateConfig.ISO8601dateFormat
        return formatter
    }()

    var syncTimer: Timer? = nil

    // Array of collected closures to call when sync is complete due to multiple triggers.
    var closuresToPerformWhenSyncComplete: [(_ error: AppError?) -> Void] = []


    // DAL's  (Data Access Layer)
    let supervisorsDAL = RLMSupervisor()
    let unitsDAL = RLMUnit()
//    let workflowStatesDAL = RLMWorkflowState()
//    let locationsDAL = RLMLocation()
//    let signAnnotationsDAL = RLMSignAnnotation()
//    let commentsDAL = RLMComment()
//    let signTypesDAL = RLMSignType()
//    let usersDAL = RLMUser()
//    let iconsDAL = RLMIcon()
//    let colorsDAL = RLMColor()
//    let textChoicesDAL = RLMTextChoice()


    // states
    var syncSupervisorDetailsStatus: SyncStatus = .unknown {
        didSet {
            DDLogDebug("♻️ .syncStateChanged to \(syncSupervisorDetailsStatus)")
        }
    }

    var syncUnitDetailsStatus: SyncStatus = .unknown {
        didSet {
            DDLogDebug("♻️ .syncStateChanged to \(syncUnitDetailsStatus)")
        }
    }


    var syncAllStatus: SyncStatus = .unknown {
        didSet {
            DDLogDebug("♻️ .syncStateChanged to \(syncAllStatus)")
            if syncAllStatus == .syncing {
                UIApplication.shared.isIdleTimerDisabled = true
            } else if syncAllStatus == .complete {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }


    var isSyncing: Bool {
        if self.syncSupervisorDetailsStatus == .syncing ||
            self.syncUnitDetailsStatus == .syncing //||
//            self.syncLocationStatus == .syncing ||
//            self.syncLocationPlanStatus == .syncing ||
//            self.syncSignAnnotationStatus == .syncing ||
//            self.syncSignTypeStatus == .syncing ||
//            self.syncWorkflowStateStatus == .syncing ||
//            self.syncCommentStatus == .syncing ||
//            self.syncAttachmentStatus == .syncing ||
//            self.syncUserStatus == .syncing ||
//            self.syncArtworkStatus == .syncing ||
//            self.syncIconStatus == .syncing ||
//            self.syncIconImageStatus == .syncing ||
//            self.syncColorStatus == .syncing ||
//            self.syncTextChoiceStatus == .syncing ||
//            self.syncAllStatus == .syncing {
        {
            return true
        } else {
            return false
        }
    }

    func print_isSyncingStatus_description() {
//        DDLogDebug("syncOrgStatus = \(syncEngine.syncOrgStatus)")
//        DDLogDebug("syncProjectStatus = \(syncEngine.syncProjectStatus)")
//        DDLogDebug("syncLocationStatus = \(syncEngine.syncLocationStatus)")
//        DDLogDebug("syncLocationPlanStatus = \(syncEngine.syncLocationPlanStatus)")
//        DDLogDebug("syncSignAnnotationStatus = \(syncEngine.syncSignAnnotationStatus)")
//        DDLogDebug("syncSignTypeStatus = \(syncEngine.syncSignTypeStatus)")
//        DDLogDebug("syncWorkflowStateStatus = \(syncEngine.syncWorkflowStateStatus)")
//        DDLogDebug("syncCommentStatus = \(syncEngine.syncCommentStatus)")
//        DDLogDebug("syncAttachmentStatus = \(syncEngine.syncAttachmentStatus)")
//        DDLogDebug("syncUserStatus = \(syncEngine.syncUserStatus)")
//        DDLogDebug("syncArtworkStatus = \(syncEngine.syncArtworkStatus)")
//        DDLogDebug("syncIconStatus = \(syncEngine.syncIconStatus)")
//        DDLogDebug("syncIconImageStatus = \(syncEngine.syncIconImageStatus)")
//        DDLogDebug("syncColorStatus = \(syncEngine.syncColorStatus)")
//        DDLogDebug("syncTextChoiceStatus = \(syncEngine.syncTextChoiceStatus)")
//        DDLogDebug("syncAllStatus = \(syncEngine.syncAllStatus)")
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


    // MARK: -
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didCompleteSyncAll), name: .didCompleteSync, object: SyncEngine.self)
    }


    deinit {
        NotificationCenter.default.removeObserver(self)
        DDLogWarn("\(self)")
    }


}
