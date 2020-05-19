import Foundation
import CocoaLumberjack


extension SyncEngine {
    func syncDOWNUnitStories(_ syncCompletion: @escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 Unit stories")

        if appSession.userProfile.isSupervisor {
            if let unitId = RLMSupervisor.details?.primaryUnitId {
                UnitAPIService.getPublishedStories(unitId: unitId) { [weak self] result in
                    switch result {
                    case .success(let stories):
                        // link with unit
                        let unit = RLMUnit.find(withID: unitId)
                        stories.forEach({ $0.unit = unit })
                        // Update with new data.
                        RLMStory.createOrUpdateAll(with: stories)
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMStory.className())\' items in DB: \(RLMStory.findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else {
            let allSubjects = RLMSubject.findAll()
            if !allSubjects.isEmpty {

                var unitIds = Set<String>()
                // get all unique unit ids
                allSubjects.forEach({ $0.unitIds.forEach({ unitIds.insert($0)}) })

                let operationQueue = OperationQueue()
                var apiResult: Result<[RLMStory], AppError>?

                let completionOperation = BlockOperation {
                    guard let apiResult = apiResult else {
                        // TODO: msg
                        syncCompletion(nil)
                        return
                    }
                    DDLogDebug("sync completion block")
                    self.syncStates[syncKey] = .complete

                    switch apiResult {
                    case .success:
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMStory.className())\' items in DB: \(RLMStory.findAll().count)")
                        syncCompletion(nil)
                    case .failure(let error):
                        syncCompletion(error)
                    }
                }

                for (index, unitId) in unitIds.enumerated() {
                    let operation = BlockOperation {
                        if self.syncStates[syncKey] == .complete {  // nothing more to do.
                            return
                        }

                        let semaphore = DispatchSemaphore(value: 0) // serialize async API executions in this thread.

                        UnitAPIService.getPublishedStories(unitId: unitId) { [weak self] result in
                            DDLogDebug("#️⃣ \(index+1) of \(unitIds.count) Unit(s)")
                            apiResult = result

                            switch result {
                            case .success(let stories):
                                // link with unit
                                let unit = RLMUnit.find(withID: unitId)
                                stories.forEach({ $0.unit = unit })
                                // Update with new data.
                                RLMStory.createOrUpdateAll(with: stories)
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
