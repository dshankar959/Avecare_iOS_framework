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
        if appSession.userProfile.isSupervisor {

            if let unitId = RLMSupervisor.details?.primaryUnitId,
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
            }

        } else {  // guardian

            if let organizationId = RLMOrganization.findAll().first?.id {
                OrganizationsAPIService.getAvailableActivities(for: organizationId) { [weak self] result in
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
//                        // non-fatal?
//                        if error.code == "403" {
//                            syncCompletion(nil)
//                        } else {
//                            syncCompletion(error)
//                        }
                    }
                }
            }
        }
    }


    func syncUPOrganizationActivities(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing up 🔺 Organization Activities")

        // Collect any `reminder` objects that have their publish state set to `publishing`.
        let allActivitiesForPublishing = RLMActivity.findAllToSync(detached: true)

        DDLogVerbose("Activity objects to sync up = \(allActivitiesForPublishing.count)")
        notifySyncStateChanged(message: "\(allActivitiesForPublishing.count) activities remaining to sync up ↑")

        if allActivitiesForPublishing.count <= 0 {
            DDLogDebug("⬆️ UP syncComplete!")
            syncStates[syncKey] = .complete
            syncCompletion(nil)
            return
        }

        let activity = allActivitiesForPublishing.first!

        if let unitId = RLMSupervisor.details?.primaryUnitId {

            NotificationsAPIService.publishActivity(uintId: unitId, data: activity, completion: { [weak self] result in
                switch result {
                case .success(let publishedActivity):

                    publishedActivity.publishState = .published
                    DDLogDebug("⬆️ UP syncComplete!  activity.id = \(publishedActivity.id)")
                    RLMActivity.createOrUpdateAll(with: [publishedActivity], update: true)

                    self?.syncUPOrganizationActivities(syncCompletion)    // recurse for anymore

                case .failure(let error):
                    self?.syncStates[syncKey] = .complete
                    DDLogError("\(error)")
                    syncCompletion(error)
                }
            })
        } else {
            syncStates[syncKey] = .complete
            let error = AppError(title: "🤔", userInfo: "Missing unit id", code: "🤔", type: "")    // should never happen.
            syncCompletion(error)
            return
        }
    }

}
