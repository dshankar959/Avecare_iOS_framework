import CocoaLumberjack



extension SyncEngine {

    func syncDOWNsupervisorDetails(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogDebug("")

        if self.isSyncBlocked {
            self.syncSupervisorDetailsStatus = .complete
            syncCompletion(isSyncCancelled ? nil : NetworkError.NetworkConnectionLost.message)
            return
        }

        if self.syncSupervisorDetailsStatus == .syncing {
            DDLogDebug("syncAccountInfoStatus =🔄= .syncing")
//            syncCompletion(nil)
//            return
        }
        self.syncSupervisorDetailsStatus = .syncing
        notifySyncStateChanged(message: "Syncing down ↓ supervisor details")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let supervisorId = appSession.userProfile.accountTypeId {
                SupervisorsAPIService.getSupervisorDetails(for: supervisorId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        // Update with new data.
                        self?.supervisorsDAL.createOrUpdateAll(with: [details])
                        DDLogDebug("⬇️ DOWN syncComplete!  Total items in DB: \(self?.supervisorsDAL.findAll().count ?? -1)")
                        self?.syncSupervisorDetailsStatus = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncSupervisorDetailsStatus = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else {  // guardian
        }

    }


}
