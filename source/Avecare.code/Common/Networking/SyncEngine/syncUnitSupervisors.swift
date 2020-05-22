import CocoaLumberjack



extension SyncEngine {

    // Sync down supervisor profile details across all available units.
    func syncUnitSupervisors(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 unit supervisor accounts")

        let allUnits = RLMUnit.findAll()
        if !allUnits.isEmpty {
            var apiResult: Result<[SupervisorAccount], AppError> = .success([SupervisorAccount()])
            let operationQueue = OperationQueue()

            let completionOperation = BlockOperation {
                DDLogDebug("sync completion block")
                self.syncStates[syncKey] = .complete

                switch apiResult {
                case .success:
                    syncCompletion(nil)
                case .failure(let error):
                    syncCompletion(error)
                }
            }

            var operations: [BlockOperation] = []

            for (index, unit) in allUnits.enumerated() {
                let unitId = unit.id

                let operation = BlockOperation {
                    if self.syncStates[syncKey] == .complete {  // nothing more to do.
                        return
                    }

                    let semaphore = DispatchSemaphore(value: 0) // serialize async API executions in this thread.

                    // Get list of supervisors for this unit.
                    UnitAPIService.getSupervisorAccounts(unitId: unitId) { [weak self] result in
                        DDLogDebug("#️⃣ \(index+1) of \(allUnits.count) Unit(s)")
                        apiResult = result

                        switch result {
                        case .success(let supervisorAccounts):
                            DDLogDebug("getSupervisorAccounts: .success")

                            // Now get the profile details for each supervisor in the list.
                            self?.syncSupervisorProfiles(supervisorAccounts) { [weak self] error in
                                if let error = error {
                                    apiResult = .failure(error)
                                    self?.syncStates[syncKey] = .complete
                                } else {
                                    DDLogDebug("syncSupervisorProfiles: #️⃣ \(index+1) .success")
                                }

                                semaphore.signal()
                            }

                        case .failure:
                            self?.syncStates[syncKey] = .complete
                            semaphore.signal()
                        }
                    }
                    semaphore.wait()
                }   // end-of-BlockOperation

                operations.append(operation)
                completionOperation.addDependency(operation)
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



extension SyncEngine {

    private func syncSupervisorProfiles(_ accounts: [SupervisorAccount], syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 supervisor profiles")

        // Sync down supervisor details from list.
        if !accounts.isEmpty {
            var apiResult: Result<RLMSupervisor, AppError> = .success(RLMSupervisor())
            let operationQueue = OperationQueue()

            let completionOperation = BlockOperation {
                DDLogDebug("sync completion block")
                self.syncStates[syncKey] = .complete

                switch apiResult {
                case .success:
                    DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMSupervisor.className())\' items in DB: \(RLMSupervisor.findAll().count)")
                    syncCompletion(nil)
                case .failure(let error):
                    syncCompletion(error)
                }
            }

            var operations: [BlockOperation] = []

            for (index, supervisorAccount) in accounts.enumerated() {

                if appSession.userProfile.isGuardian, supervisorAccount.isUnitType == true {
                    // ignore "Room" type profiles
                    continue
                }

                let operation = BlockOperation {
                    if self.syncStates[syncKey] == .complete {  // nothing more to do.
                        return
                    }

                    let semaphore = DispatchSemaphore(value: 0) // serialize async API executions in this thread.

                    SupervisorsAPIService.getSupervisorDetails(for: supervisorAccount.supervisorId) { [weak self] result in
                        DDLogDebug("#️⃣ \(index+1) of \(accounts.count) Supervisor Profile(s)")
                        apiResult = result

                        switch result {
                        case .success(let details):
                            if let existingSupervisor = RLMSupervisor.find(withID: details.id) {
                                existingSupervisor.clean()  // note: clears the linked list of objects only
                            }
                            // Update with new data.
                            RLMSupervisor.createOrUpdateAll(with: [details])
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
