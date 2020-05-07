import CocoaLumberjack



extension SyncEngine {

    func syncDOWNunitDetails(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogDebug("")

        if self.isSyncBlocked {
            self.syncUnitDetailsStatus = .complete
            syncCompletion(isSyncCancelled ? nil : NetworkError.NetworkConnectionLost.message)
            return
        }

        if self.syncUnitDetailsStatus == .syncing {
            DDLogDebug("syncUnitDetailsStatus =🔄= .syncing")
//            syncCompletion(nil)
//            return
        }
        self.syncUnitDetailsStatus = .syncing
        notifySyncStateChanged(message: "Syncing down ↓ unit details")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let unitId = RLMSupervisor().details?.primaryUnitId {
                UnitAPIService.getUnitDetails(id: unitId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        // Update with new data.
                        self?.unitsDAL.createOrUpdateAll(with: [details])
                        DDLogDebug("⬇️ DOWN syncComplete!  Total items in DB: \(self?.unitsDAL.findAll().count ?? -1)")
                        self?.syncUnitDetailsStatus = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncUnitDetailsStatus = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else {  // guardian
        }

    }


}
