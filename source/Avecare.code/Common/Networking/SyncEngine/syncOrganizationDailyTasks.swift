import CocoaLumberjack



extension SyncEngine {

    func syncDOWNorganizationDailyTasks(_ syncCompletion: @escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 organization daily tasks")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor,
           let unitId = RLMSupervisor.details?.primaryUnitId,
            let unitDetails = RLMUnit.details(for: unitId),
            let institutionDetails = RLMInstitution.details(for: unitDetails.institutionId) {
            OrganizationsAPIService.getAvailableDailyTasks(for: institutionDetails.organizationId) { [weak self] result in
                switch result {
                case .success(let dailyTasks):
                    // Update with new data.
                    RLMDailyTaskOption.createOrUpdateAll(with: dailyTasks)
                    DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMDailyTaskOption.className())\' items in DB: \(RLMDailyTaskOption.findAll().count)")
                    self?.syncStates[syncKey] = .complete
                    syncCompletion(nil)
                case .failure(let error):
                    self?.syncStates[syncKey] = .complete
                    syncCompletion(error)
                }
            }
        } else {
            DDLogWarn("Nothing to sync down here for Guardian")
            self.syncStates[syncKey] = .complete
            syncCompletion(nil)
        }
    }

}
