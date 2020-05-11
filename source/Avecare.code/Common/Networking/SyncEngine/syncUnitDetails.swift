import CocoaLumberjack



extension SyncEngine {

    func syncDOWNunitDetails(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogDebug("")
        let unitsDAL = RLMUnit()

        // Use function name as key.
        let syncKey = "\(#function)".removeBrackets()

        if self.isSyncBlocked {
            syncStates[syncKey] = .complete
            syncCompletion(isSyncCancelled ? nil : NetworkError.NetworkConnectionLost.message)
            return
        }

        if syncStates[syncKey] == .syncing {
            DDLogDebug("\(syncKey) =🔄= .syncing")
//            syncCompletion(nil)
//            return
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
                        unitsDAL.createOrUpdateAll(with: [details])
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMUnit.className())\' items in DB: \(unitsDAL.findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else { // guardian
            let allSubjects = RLMSubject().findAll()
            if !allSubjects.isEmpty {

                let operationQueue = OperationQueue()
                operationQueue.maxConcurrentOperationCount = 1

                let completionOperation = BlockOperation {
                    DDLogDebug("completionOperation ...")
                }

                for (index, subject) in allSubjects.enumerated() {
                    if syncStates[syncKey] == .complete {
                        return
                    }

                    if let unitId = subject.unitIds.first {
                        let operation = BlockOperation {
                            UnitAPIService.getUnitDetails(unitId: unitId) { [weak self] result in
                                DDLogDebug("#️⃣ \(index+1) of \(allSubjects.count)")

                                switch result {
                                case .success(let details):
                                    // Update with new data.
                                    unitsDAL.createOrUpdateAll(with: [details])

                                    if (index+1) == allSubjects.count {
                                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMUnit.className())\' items in DB: \(unitsDAL.findAll().count)")
                                        self?.syncStates[syncKey] = .complete
                                        syncCompletion(nil)
                                    }

                                case .failure(let error):
                                    self?.syncStates[syncKey] = .complete
                                    syncCompletion(error)
                                    return
                                }
                            }
                        }   // BlockOperation
                        completionOperation.addDependency(operation)
                        operationQueue.addOperation(operation)
                    }
                }

                OperationQueue.main.addOperation(completionOperation)
            }
        }

    }


}
