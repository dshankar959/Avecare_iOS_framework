import Foundation
import CocoaLumberjack

extension SyncEngine {
    func syncOrganizationTemplates(_ syncCompletion: @escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 organization details")

        if appSession.userProfile.isSupervisor,
           let unitId = RLMSupervisor.details?.primaryUnitId, let unitDetails = RLMUnit.details(for: unitId),
           let institutionDetails = RLMInstitution.details(for: unitDetails.institutionId) {
            OrganizationsAPIService.getOrganizationLogTemplates(id: institutionDetails.organizationId) { [weak self] result in
                switch result {
                case .success(let templates):
                    // delete old templates
                    RLMFormTemplate.findAll().forEach({
                        $0.clean()
                        $0.delete()
                    })

                    // link with organization
                    guard let organization = RLMOrganization.details(for: institutionDetails.organizationId) else {
                        // FIXME: add error processing if needed
                        fatalError()
                    }
                    templates.forEach({ $0.organization = organization })

                    // save downloaded templates
                    RLMFormTemplate.createOrUpdateAll(with: templates)
                    DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMFormTemplate.className())\' items in DB: \(RLMFormTemplate.findAll().count)")
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