import CocoaLumberjack



extension SyncEngine {

    func syncDOWNorganizationTemplates(_ syncCompletion: @escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 organization templates")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let unitId = RLMSupervisor.details?.primaryUnitId,
                let unitDetails = RLMUnit.details(for: unitId),
                let institutionDetails = RLMInstitution.details(for: unitDetails.institutionId) {
                OrganizationsAPIService.getOrganizationLogTemplates(id: institutionDetails.organizationId) { [weak self] result in
                    switch result {
                    case .success(let templates):
                        // Refresh with a full delete of all existing form templates.
                        RLMFormTemplate.findAll().forEach({
                            $0.clean()
                            $0.delete()
                        })

/*                        // Will we ever have more then one org. at a time?
                        guard let organization = RLMOrganization.details(for: institutionDetails.organizationId) else {
                            fatalError()
                        }
                        // link with organization  (inverse relationship).  Is this even needed???
                        templates.forEach({ $0.organization = organization })
*/
                        // save downloaded template(s)
                        RLMFormTemplate.createOrUpdateAll(with: templates)
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMFormTemplate.className())\' items in DB: \(RLMFormTemplate.findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else {
            DDLogWarn("Nothing to sync down here for Guardian")
        }
    }
}
