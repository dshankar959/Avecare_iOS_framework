import CocoaLumberjack



extension SyncEngine {

    func syncDOWNorganizationActivities(_ syncCompletion: @escaping (_ error: AppError?) -> Void) {
        DDLogVerbose("")

        // Use function name as key.
        let syncKey = "\(#function)".removeBrackets()

        if self.isSyncBlocked {
            syncStates[syncKey] = .complete
            syncCompletion(isSyncCancelled ? nil : NetworkError.NetworkConnectionLost.message)
            return
        }

        if syncStates[syncKey] == .syncing {
            DDLogDebug("\(syncKey) =🔄= .syncing")
        }

        syncStates[syncKey] = .syncing
        notifySyncStateChanged(message: "Syncing down 🔻 organization activities")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor,
           let unitId = RLMSupervisor.details?.primaryUnitId,
            let unitDetails = RLMUnit.details(for: unitId),
            let institutionDetails = RLMInstitution.details(for: unitDetails.institutionId) {
            OrganizationsAPIService.getAvailableActivities(for: institutionDetails.organizationId) { [weak self] result in
                switch result {
                case .success(let activities):
                    // Update with new data.
                    RLMActivityOption.createOrUpdateAll(with: activities)
                    DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMActivityOption.className())\' items in DB: \(RLMActivityOption.findAll().count)")
                    self?.syncStates[syncKey] = .complete
                    syncCompletion(nil)
                case .failure(let error):
                    self?.syncStates[syncKey] = .complete
                    syncCompletion(error)
                }
            }
        } else {
            // TODO: ???
        }
    }
}
