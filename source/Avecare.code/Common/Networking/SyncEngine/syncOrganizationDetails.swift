import CocoaLumberjack



extension SyncEngine {

    func syncDOWNorganizationDetails(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogDebug("")

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
        notifySyncStateChanged(message: "Syncing down 🔻 organization details")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let unitId = RLMSupervisor.details?.primaryUnitId,
                let unitDetails = RLMUnit.details(for: unitId),
                let institutionDetails = RLMInstitution.details(for: unitDetails.institutionId) {
                OrganizationsAPIService.getOrganizationDetails(id: institutionDetails.organizationId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        // Update with new data.
                        RLMOrganization.createOrUpdateAll(with: [details])
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMOrganization.className())\' items in DB: \(RLMOrganization.findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else {  // guardian
            if let institutionDetails = RLMInstitution.findAll().first {
                OrganizationsAPIService.getOrganizationDetails(id: institutionDetails.organizationId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        // Update with new data.
                        RLMOrganization.createOrUpdateAll(with: [details])
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMOrganization.className())\' items in DB: \(RLMOrganization.findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            } else {
                DDLogError("Missing data.")
                fatalError("Missing data.")
            }
        }

    }


}
