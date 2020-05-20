import CocoaLumberjack



extension SyncEngine {

    func syncDOWNunitDetails(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 unit details")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let unitId = RLMSupervisor.details?.primaryUnitId {
                UnitAPIService.getUnitDetails(unitId: unitId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        // Update with new data.
                        RLMUnit.createOrUpdateAll(with: [details])
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMUnit.className())\' items in DB: \(RLMUnit.findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else { // guardian
            // Sync down unit details across all subjects.
            let allSubjects = RLMSubject.findAll()
            if !allSubjects.isEmpty {
                var apiResult: Result<RLMUnit, AppError> = .success(RLMUnit())
                let operationQueue = OperationQueue()

                let completionOperation = BlockOperation {
                    DDLogDebug("sync completion block")
                    self.syncStates[syncKey] = .complete

                    switch apiResult {
                    case .success:
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMUnit.className())\' items in DB: \(RLMUnit.findAll().count)")
                        syncCompletion(nil)
                    case .failure(let error):
                        syncCompletion(error)
                    }
                }

                var operations: [BlockOperation] = []

                for (index, subject) in allSubjects.enumerated() {
                    if let unitId = subject.unitIds.first {

                        let operation = BlockOperation {
                            if self.syncStates[syncKey] == .complete {  // nothing more to do.
                                return
                            }

                            let semaphore = DispatchSemaphore(value: 0) // serialize async API executions in this thread.

                            UnitAPIService.getUnitDetails(unitId: unitId) { [weak self] result in
                                DDLogDebug("#️⃣ \(index+1) of \(allSubjects.count) Subject(s)")
                                apiResult = result

                                switch result {
                                case .success(let details):
                                    // Update with new data.
                                    RLMUnit.createOrUpdateAll(with: [details])
                                case .failure:
                                    self?.syncStates[syncKey] = .complete
                                }

                                semaphore.signal()
                            }

                            semaphore.wait()
                        }   // end-of-BlockOperation

                        operations.append(operation)
                        completionOperation.addDependency(operation)
                    }
                }

                // FIFO
                for (index, op) in operations.enumerated() {
                    if index == 0 {
                        continue    // skip first one.
                    }
                    // Depend on previous one.
                    op.addDependency(operations[index-1])
                }

                OperationQueue.main.addOperation(completionOperation)
                operationQueue.addOperations(operations, waitUntilFinished: false)  // trigger!
            }
        }

    }


}
