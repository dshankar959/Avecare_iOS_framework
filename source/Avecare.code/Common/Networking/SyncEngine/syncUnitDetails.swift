import CocoaLumberjack



extension SyncEngine {

    func syncDOWNunitDetails(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogDebug("")
        let unitsDAL = RLMUnit()

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
        notifySyncStateChanged(message: "Syncing down 🔻 unit details")

        // Sync down from server and update our local DB.
        if let unitId = RLMSupervisor.details?.primaryUnitId {
            UnitAPIService.getUnitDetails(unitId: unitId) { [weak self] result in
                switch result {
                case .success(let details):
                    // Update with new data.
                    unitsDAL.createOrUpdateAll(with: [details])
                    DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMUnit.className())\' items in DB: \(unitsDAL.findAll().count)")
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
