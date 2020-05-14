import CocoaLumberjack



extension SyncEngine {

    func syncDOWNsubjects(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogDebug("")
        let subjectsDAL = RLMSubject()

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
        notifySyncStateChanged(message: "Syncing down 🔻 subject details")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let unitId = RLMSupervisor.details?.primaryUnitId {
                UnitAPIService.getSubjects(unitId: unitId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        // Update with new data.
                        subjectsDAL.createOrUpdateAll(with: details)
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMSubject.className())\' items in DB: \(RLMSubject().findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else {  // guardian
            if let guardianId = appSession.userProfile.accountTypeId {
                GuardiansAPIService.getSubjects(for: guardianId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        // Update with new data.
                        RLMGuardian().createOrUpdateAll(with: details)
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMSubject.className())\' items in DB: \(RLMSubject().findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        }

}


}
