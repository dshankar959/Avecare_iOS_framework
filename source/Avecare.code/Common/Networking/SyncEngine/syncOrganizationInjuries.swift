import CocoaLumberjack



extension SyncEngine {

    func syncDOWNorganizationInjuries(_ syncCompletion: @escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 organization injuries")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let unitId = RLMSupervisor.details?.primaryUnitId,
                let unitDetails = RLMUnit.details(for: unitId),
                let institutionDetails = RLMInstitution.details(for: unitDetails.institutionId) {
                OrganizationsAPIService.getAvailableInjuries(for: institutionDetails.organizationId) { [weak self] result in
                    switch result {
                    case .success(let injuries):
                        // Update with new data.
                        RLMInjuryOption.createOrUpdateAll(with: injuries)
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInjuryOption.className())\' items in DB: \(RLMInjuryOption.findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else { // guardian
            if let organizationId = RLMOrganization.findAll().first?.id {
                OrganizationsAPIService.getAvailableInjuries(for: organizationId) { [weak self] result in
                    switch result {
                    case .success(let injuries):
                        // Update with new data.
                        RLMInjuryOption.createOrUpdateAll(with: injuries)
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInjuryOption.className())\' items in DB: \(RLMInjuryOption.findAll().count)")
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

    
    func syncUPinjuries(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing up 🔺 Subject Injuries")

        // Collect any `reminder` objects that have their publish state set to `publishing`.
        let allInjuriesForPublishing: [RLMInjury]

        allInjuriesForPublishing = RLMInjury.findAllToSync()

        DDLogVerbose("Injury objects to sync up = \(allInjuriesForPublishing.count)")
        notifySyncStateChanged(message: "\(allInjuriesForPublishing.count) injuries remaining to sync up ↑")

        if allInjuriesForPublishing.count <= 0 {
            DDLogDebug("⬆️ UP syncComplete!")
            syncStates[syncKey] = .complete
            syncCompletion(nil)
            return
        }

        NotificationsAPIService.publishInjuries(data: allInjuriesForPublishing, completion: { [weak self] result in
            switch result {
            case .success(let publishedInjuries):
                for injury in publishedInjuries {
                    injury.publishState = .published
                    DDLogDebug("⬆️ UP syncComplete!  injury.id = \(injury.id)")
                }
                RLMInjury.createOrUpdateAll(with: publishedInjuries, update: true)

                self?.syncUPinjuries(syncCompletion)    // recurse for anymore

            case .failure(let error):
                self?.syncStates[syncKey] = .complete
                DDLogError("\(error)")
                syncCompletion(error)
            }
        })
    }

}
