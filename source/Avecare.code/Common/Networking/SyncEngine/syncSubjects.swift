import CocoaLumberjack



extension SyncEngine {

    func syncDOWNsubjects(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 subject details")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let unitId = RLMSupervisor.details?.primaryUnitId {
                UnitAPIService.getSubjects(unitId: unitId) { [weak self] result in
                    switch result {
                    case .success(let details):

                        let existingSubjects = RLMSubject.findAll()
                        existingSubjects.forEach { existingSubject in
                            var existInServer = false

                            for subject in details where subject == existingSubject {
                                existInServer = true
                                break
                            }

                            if !existInServer {
                                existingSubject.delete() // safely remove because it doesn't have linked object
                            }

                        }

                        // Update with new data.
                        RLMSubject.createOrUpdateAll(with: details)
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMSubject.className())\' items in DB: \(RLMSubject.findAll().count)")
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
                        RLMSubject.createOrUpdateAll(with: details)
/*
                        // Delete any subject's that have been removed from a unit.
                        RLMSubject.findAll().forEach({
                            if $0.unitIds.isEmpty {    // a subject that doesn't belong to a unit?
                                $0.delete()
                            }
                        })
*/
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMSubject.className())\' items in DB: \(RLMSubject.findAll().count)")
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
