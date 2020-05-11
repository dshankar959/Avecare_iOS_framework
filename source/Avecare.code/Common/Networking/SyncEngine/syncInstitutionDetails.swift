import CocoaLumberjack



extension SyncEngine {

    func syncDOWNinstitutionDetails(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogDebug("")
        let institutionsDAL = RLMInstitution()

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
        notifySyncStateChanged(message: "Syncing down 🔻 institution details")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let unitId = RLMSupervisor.details?.primaryUnitId, let unitDetails = RLMUnit.details(for: unitId) {
                InstitutionsAPIService.getInstitutionDetails(id: unitDetails.institutionId) { [weak self] result in
                    switch result {
                    case .success(let details):
                        // Update with new data.
                        institutionsDAL.createOrUpdateAll(with: [details])
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInstitution.className())\' items in DB: \(RLMInstitution().findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else { // guardian
            let allUnits = RLMUnit().findAll()
            if !allUnits.isEmpty {
/*
                for unit in allUnits {
                    InstitutionsAPIService.getInstitutionDetails(id: unit.institutionId) { [weak self] result in
                        switch result {
                        case .success(let details):
                            // Update with new data.
                            institutionsDAL.createOrUpdateAll(with: [details])
                        case .failure(let error):
                            self?.syncStates[syncKey] = .complete
                            syncCompletion(error)
                        }
                    }
                }

                DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInstitution.className())\' items in DB: \(RLMInstitution().findAll().count)")
                syncStates[syncKey] = .complete
                syncCompletion(nil)
*/


/*
                for (index, unit) in allUnits.enumerated() {
                    InstitutionsAPIService.getInstitutionDetails(id: unit.institutionId) { [weak self] result in
                        switch result {
                        case .success(let details):
                            // Update with new data.
                            institutionsDAL.createOrUpdateAll(with: [details])

                            DDLogDebug("index = \(index) of \(allUnits.count)")

                            if (index+1) == allUnits.count {
                                DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInstitution.className())\' items in DB: \(RLMInstitution().findAll().count)")
                                self?.syncStates[syncKey] = .complete
                                syncCompletion(nil)
                            }


                        case .failure(let error):
                            self?.syncStates[syncKey] = .complete
                            syncCompletion(error)
                        }
                    }
                }
*/



/*
                var apiResult: Result<RLMInstitution, AppError> = .success(RLMInstitution())

                for unit in allUnits {
                    let semaphore = DispatchSemaphore(value: 0) // serialize async API executions.

                    InstitutionsAPIService.getInstitutionDetails(id: unit.institutionId) { result in
                        apiResult = result
                        semaphore.signal()
                    }

                    semaphore.wait()

                    switch apiResult {
                    case .success(let details):
                        // Update with new data.
                        institutionsDAL.createOrUpdateAll(with: [details])

                    case .failure:
                        break
                    }

                }

                switch apiResult {
                case .success:
                    DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInstitution.className())\' items in DB: \(RLMInstitution().findAll().count)")
                    self.syncStates[syncKey] = .complete
                    syncCompletion(nil)
                case .failure(let error):
                    syncStates[syncKey] = .complete
                    syncCompletion(error)
                }
*/


                var apiResult: Result<RLMInstitution, AppError> = .success(RLMInstitution())

                let operationQueue = OperationQueue()
                operationQueue.maxConcurrentOperationCount = 1

                let completionOperation = BlockOperation {
                    DDLogDebug("sync completion block")

                    switch apiResult {
                    case .success:
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInstitution.className())\' items in DB: \(RLMInstitution().findAll().count)")
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
                        if self.syncStates[syncKey] == .complete {
                            return
                        }

                        let semaphore = DispatchSemaphore(value: 0) // serialize async API executions.

                        InstitutionsAPIService.getInstitutionDetails(id: institutionId) { [weak self] result in
                            DDLogDebug("#️⃣ \(index+1) of \(allUnits.count)")
                            apiResult = result

                            switch result {
                            case .success(let details):
                                // Update with new data.
                                institutionsDAL.createOrUpdateAll(with: [details])
                            case .failure:
                                self?.syncStates[syncKey] = .complete
                            }

                            semaphore.signal()
                        }

                        semaphore.wait()

                    }   // BlockOperation

                    completionOperation.addDependency(operation)
                    operationQueue.addOperation(operation)
                }

                OperationQueue.main.addOperation(completionOperation)


//                DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInstitution.className())\' items in DB: \(RLMInstitution().findAll().count)")
//                self.syncStates[syncKey] = .complete
//                syncCompletion(nil)


/*
                let serialQueue = DispatchQueue(label: "com.avecare.\(syncKey)")

                for (index, unit) in allUnits.enumerated() {
                    if syncStates[syncKey] == .complete {
                        return
                    }

                    let institutionId = unit.institutionId

                    serialQueue.async(flags: .barrier) {
                        InstitutionsAPIService.getInstitutionDetails(id: institutionId) { [weak self] result in
                            DDLogDebug("#️⃣ \(index+1) of \(allUnits.count)")



                            switch result {
                            case .success(let details):
                                // Update with new data.
                                institutionsDAL.createOrUpdateAll(with: [details])

                                if (index+1) == allUnits.count {
                                    DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInstitution.className())\' items in DB: \(RLMInstitution().findAll().count)")
                                    self?.syncStates[syncKey] = .complete
                                    syncCompletion(nil)
                                }

                            case .failure(let error):
                                self?.syncStates[syncKey] = .complete
                                syncCompletion(error)
                                return
                            }
                        }
                    }   // serialQueue.async

                }

*/



/*
                let mainQueue = OperationQueue.main
                mainQueue.maxConcurrentOperationCount = 1
//                mainQueue.waitUntilAllOperationsAreFinished()

                let operationBlock1 = BlockOperation()
                let operationBlock2 = BlockOperation()
                let operationBlock3 = BlockOperation()

                operationBlock1.addExecutionBlock {
                    InstitutionsAPIService.getInstitutionDetails(id: allUnits[0].institutionId) { [weak self] result in
                        switch result {
                        case .success(let details):
                            // Update with new data.
                            institutionsDAL.createOrUpdateAll(with: [details])
                        case .failure(let error):
                            self?.syncStates[syncKey] = .complete
                            syncCompletion(error)
                        }
                    }
                }

                operationBlock2.addExecutionBlock {
                    InstitutionsAPIService.getInstitutionDetails(id: allUnits[1].institutionId) { [weak self] result in
                        switch result {
                        case .success(let details):
                            // Update with new data.
                            institutionsDAL.createOrUpdateAll(with: [details])
                        case .failure(let error):
                            self?.syncStates[syncKey] = .complete
                            syncCompletion(error)
                        }
                    }
                }


                operationBlock3.addExecutionBlock {
                    DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMInstitution.className())\' items in DB: \(RLMInstitution().findAll().count)")
                    self.syncStates[syncKey] = .complete
                    syncCompletion(nil)
                }

                //Add dependency as required
//                operationBlock3.addDependency(operationBlock2)
//                operationBlock2.addDependency(operationBlock1)

                mainQueue.addOperations([operationBlock1,
                                         operationBlock2,
                                         operationBlock3], waitUntilFinished: false)
*/



            }
        }

    }


}
