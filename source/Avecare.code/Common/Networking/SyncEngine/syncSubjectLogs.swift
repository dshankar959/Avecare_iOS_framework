import CocoaLumberjack
import RealmSwift

extension SyncEngine {
    func syncDOWNSubjectLogs(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 subject logs")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            // TODO: load only today's logs
        } else {
            let subjectIDs = RLMSubject.findAll().map({ $0.id })

            var apiResult: Result<[DailyFormAPIModel], AppError> = .success([DailyFormAPIModel]())
            let operationQueue = OperationQueue()

            let storage = ImageStorageService()

            let completionOperation = BlockOperation {
                DDLogDebug("sync completion block")
                self.syncStates[syncKey] = .complete

                switch apiResult {
                case .success:
                    DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMLogForm.className())\' items in DB: \(RLMLogForm.findAll().count)")
                    syncCompletion(nil)
                case .failure(let error):
                    syncCompletion(error)
                }
            }

            for (index, subjectId) in subjectIDs.enumerated() {
                let operation = BlockOperation {
                    if self.syncStates[syncKey] == .complete {  // nothing more to do.
                        return
                    }

                    let semaphore = DispatchSemaphore(value: 0) // serialize async API executions in this thread.
                    let request = SubjectsAPIService.SubjectLogsRequest(id: subjectId)
                    SubjectsAPIService.getLogs(request: request) { [weak self] result in
                        DDLogDebug("#️⃣ \(index+1) of \(subjectIDs.count)")

                        apiResult = result

                        switch result {
                        case .success(let apiLogs):
                            var createOrUpdate = [RLMLogForm]()

                            for apiLog in apiLogs {
                                let files = apiLog.files

                                let logForm = apiLog.log
                                // link with subject
                                logForm.subject = RLMSubject.find(withID: subjectId)
                                // set server date (not really lastUpdated)
                                logForm.serverLastUpdated = apiLog.date
                                // mark as published
                                logForm.publishState = .published

                                // save images
                                let photoRows = logForm.rows.compactMap({ $0.photo })
                                for row in photoRows {
                                    guard let file = files.first(where: { $0.id == row.id }),
                                            let url = URL(string: file.fileUrl) else {
                                        continue
                                    }
                                    do {
                                        _ = try storage.saveImage(url, name: row.id)
                                    } catch {
                                        DDLogError("Failed to save image \(url)")
                                    }
                                }

                                createOrUpdate.append(logForm)
                            }

                            // Update with new data.
                            RLMLogForm.createOrUpdateAll(with: createOrUpdate)
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