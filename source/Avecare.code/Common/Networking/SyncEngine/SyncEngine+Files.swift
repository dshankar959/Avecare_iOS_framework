import CocoaLumberjack
import RealmSwift
//import ZIPFoundation
import Moya



extension SyncEngine {
/*
    func syncUPfeedbackFile(_ filePath: URL?,
                          with comments: String,
                          progressClosure:@escaping (_ progress: Double) -> Void = { _ in },
                          syncCompletion:@escaping (_ error: AppError?) -> Void) {

        let objectID = newUUID

        let parameters: [String: Any] = [
            "object_id": objectID,
            "client_last_updated": Date.ISO8601StringFromDate(Date()),
            "comments": comments
        ]

        let moyaProgressBlock = { (_ progress: ProgressResponse) -> Void in
            progressClosure(progress.progress)
        }

        apiProvider.request(.uploadFile(ofType: RLMFeedback.self,
            objectID: objectID,
            filePathURL: filePath,
            withJSONparameters: parameters),
            callbackQueue: DispatchQueue.main,
            progress: moyaProgressBlock) { result in
                switch result {
                case .success(let response):
                    DDLogDebug("😃  .success  :  \(response)")
                    syncCompletion(nil)
                case .failure(let error):
                    DDLogDebug("🤬  .failure")
                    syncCompletion(getAppErrorFromMoya(with: error))
                }
            }
    }
*/

/*
    func syncDownIconImages(for iconID: String? = nil,
                            progressClosure:@escaping (_ progress: Double) -> Void = { _ in },
                            syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogInfo("🔂")

        if self.isSyncBlocked {
            syncCompletion(isSyncCancelled ? nil : NetworkError.NetworkConnectionLost.message)
            return
        }

        if self.syncIconImageStatus == .syncing {
            DDLogDebug("syncIconImageStatus =🔄= .syncing")
        }
        self.syncIconImageStatus = .syncing
        notifySyncStateChanged(message: "Syncing down ↓ icon images")

        let icon: RLMIcon

        if iconID != nil {
            if let iconObject = self.iconsDAL.find(withID: iconID!), iconObject.imageServerPath != nil {
                icon = iconObject
            } else {
//                DDLogError("❌  missing icon object 🤔  ❌")
                self.syncIconImageStatus = .complete
//                let error = AppError(title: "🤔",
//                                     userInfo: "No icon on server",
//                                     code: "🤔", type: NetworkError.self)
//                syncCompletion(error)
                syncCompletion(nil)
                return
            }
        } else {
            let iconsWithEmptyPaths = self.iconsDAL.findAllEmptyIcons()
            DDLogInfo("icons with empty paths: \(iconsWithEmptyPaths.count)")
            if let signObject = iconsWithEmptyPaths.first {
                icon = signObject
            } else { // no more empty paths
                DDLogDebug("⬇️ DOWN syncComplete!")
                self.syncIconImageStatus = .complete
                syncCompletion(nil)
                return
            }
        }

        let moyaProgressBlock = { (_ progress: ProgressResponse) -> Void in
            progressClosure(progress.progress)
        }

        self.iconsDAL.getFile(for: icon.id,
                              from: icon.imageServerPath!,
                              progress: moyaProgressBlock) { [unowned self] objectID, savedFilename, error in
            if let filename = savedFilename {
                DDLogDebug("saved filename = \(filename)")

                if icon.id == objectID {
                    DDLogVerbose("id's match. ✅ update DB")
                    // update DB
                    self.iconsDAL.updateIconLocalFilename(for: objectID, with: filename)
                } else {
                    DDLogError("❌ try again!")
                    self.syncDownIconImages(progressClosure: progressClosure, syncCompletion: syncCompletion)   // recurse to try again
                }

                if iconID == nil {
                    self.syncDownIconImages(progressClosure: progressClosure, syncCompletion: syncCompletion)   // recurse for more
                } else {
                    DDLogDebug("⬇️ DOWN syncComplete!")
                    self.syncIconImageStatus = .complete
                    syncCompletion(nil)
                }

            } else if let error = error {
                self.syncIconImageStatus = .complete
                syncCompletion(error)
            } else { // nil filename?  🤔
                DDLogDebug("🤔⬇️ DOWN syncComplete!  icon filename = nil")
                self.syncIconImageStatus = .complete
                syncCompletion(nil)
            }
        }

    }
*/

}
