import CocoaLumberjack



extension SyncEngine {

    func syncDOWNsupervisorDetails(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogDebug("")
        let supervisorsDAL = RLMSupervisor()

        // Use function name as key.
        let syncKey = "\(#function)".removeBrackets()

        if self.isSyncBlocked {
            syncStates[syncKey] = .complete
            syncCompletion(isSyncCancelled ? nil : NetworkError.NetworkConnectionLost.message)
            return
        }

        if syncStates[syncKey] == .syncing {
            DDLogDebug("\(syncKey) =🔄= .syncing")
//            syncCompletion(nil)
//            return
        }
        syncStates[syncKey] = .syncing
        notifySyncStateChanged(message: "Syncing down 🔻 supervisor details")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let supervisorId = appSession.userProfile.accountTypeId {
                SupervisorsAPIService.getSupervisorDetails(for: supervisorId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        if let existingSupervisor = RLMSupervisor().find(withID: details.id) {
                            existingSupervisor.clean()
                        }
                        // Update with new data.
                        supervisorsDAL.createOrUpdateAll(with: [details])
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMSupervisor.className())\' items in DB: \(supervisorsDAL.findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else {  // guardian

        }

    }


}
