import CocoaLumberjack



extension SyncEngine {

    func syncDOWNinstitutionDetails(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 institution details")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let unitId = RLMSupervisor.details?.primaryUnitId, let unitDetails = RLMUnit.details(for: unitId) {
                InstitutionsAPIService.getInstitutionDetails(id: unitDetails.institutionId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        // Update with new data.
                        RLMInstitution.createOrUpdateAll(with: [details])
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInstitution.className())\' items in DB: \(RLMInstitution.findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else { // guardian
            // Sync down institution details across all units.
            let allUnits = RLMUnit.findAll()
            if !allUnits.isEmpty {
                var apiResult: Result<RLMInstitution, AppError> = .success(RLMInstitution())
                let operationQueue = OperationQueue()

                let completionOperation = BlockOperation {
                    DDLogDebug("sync completion block")

                    switch apiResult {
                    case .success:
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInstitution.className())\' items in DB: \(RLMInstitution.findAll().count)")
                        self.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }

                for (index, unit) in allUnits.enumerated() {
                    let institutionId = unit.institutionId

                    let operation = BlockOperation {
                        if self.syncStates[syncKey] == .complete {  // nothing more to do.
                            return
                        }

                        let semaphore = DispatchSemaphore(value: 0) // serialize async API executions in this thread.

                        InstitutionsAPIService.getInstitutionDetails(id: institutionId) { [weak self] result in
                            DDLogDebug("#️⃣ \(index+1) of \(allUnits.count)")
                            apiResult = result

                            switch result {
                            case .success(let details):
                                // Update with new data.
                                RLMInstitution.createOrUpdateAll(with: [details])
                            case .failure:
                                self?.syncStates[syncKey] = .complete
                            }

                            semaphore.signal()
                        }

                        semaphore.wait()
                    }   // end-of-BlockOperation

                    completionOperation.addDependency(operation)
                    operationQueue.addOperation(operation)
                }

                OperationQueue.main.addOperation(completionOperation)
            }
        }

    }


}
