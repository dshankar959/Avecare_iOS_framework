import CocoaLumberjack



extension SyncEngine {

    func syncDOWNuserAccountDetails(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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

        if appSession.userProfile.isSupervisor {
            notifySyncStateChanged(message: "Syncing down 🔻 supervisor profile")
        } else {
            notifySyncStateChanged(message: "Syncing down 🔻 guardian profile")
        }

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let supervisorId = appSession.userProfile.accountTypeId {
                SupervisorsAPIService.getSupervisorDetails(for: supervisorId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        if let existingSupervisor = RLMSupervisor.find(withID: details.id) {
                            existingSupervisor.clean()  // note: *only* clears the linked list of objects (educationalBackground)
                        }
                        // Update with new data.
                        RLMSupervisor.createOrUpdateAll(with: [details])
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMSupervisor.className())\' items in DB: \(RLMSupervisor.findAll().count)")
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
                GuardiansAPIService.getGuardianDetails(for: guardianId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        // Update with new data.
                        RLMGuardian.createOrUpdateAll(with: [details])
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMGuardian.className())\' items in DB: \(RLMGuardian.findAll().count)")
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