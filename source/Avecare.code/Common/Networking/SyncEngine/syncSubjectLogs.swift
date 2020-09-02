import CocoaLumberjack



extension SyncEngine {

    func syncDOWNsubjectLogs(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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

        // Refresh any subject's empty daily log template in case they were missed and a template was added afterwards.
        // (no need to re-install the app)
        RLMLogForm.findAll().forEach({
            if $0.rows.isEmpty || $0.subject == nil {    // empty log? or a log with no subject?
                $0.clean()
                $0.delete()
            }
        })

        // Sync down from server and update our local DB.
        // Fetch all subject id's
        let subjectIDs = RLMSubject.findAll().map({ $0.id })

        var apiResult: Result<[LogFormAPIModel], AppError> = .success([LogFormAPIModel]())
        let operationQueue = OperationQueue()
        let storage = DocumentService()

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

        var operations: [BlockOperation] = []

        for (index, subjectId) in subjectIDs.enumerated() {

            let operation = BlockOperation {
                if self.syncStates[syncKey] == .complete {  // nothing more to do.
                    return
                }

                if appSession.userProfile.isSupervisor {
                    // Check if today's subject log is already in our database.
                    let savedLogs = RLMLogForm.findAll(withSubjectID: subjectId)
                    let sortedLogs = RLMLogForm.sortObjectsByLastUpdated(order: .orderedAscending, savedLogs)
                    if let lastSavedLog = sortedLogs.last,
                        let clientLastUpdated = lastSavedLog.clientLastUpdated,
                        Calendar.current.isDateInToday(clientLastUpdated) {
                        DDLogVerbose("Today's subject log is already in our database.")
                        return
                    }
                }

                let semaphore = DispatchSemaphore(value: 0) // serialize async API executions in this thread.
                let request = SubjectsAPIService.SubjectLogsRequest(id: subjectId)

                SubjectsAPIService.getLogs(request: request) { [weak self] result in
                    DDLogDebug("#️⃣ \(index+1) of \(subjectIDs.count)")
                    apiResult = result

                    switch result {
                    case .success(let apiLogs):
                        var subjectLogForms = [RLMLogForm]()

                        for log in apiLogs {
                            let logForm = log.logForm
                            // overwrite id with correct one from API object
                            logForm.id = log.id
                            // link with subject
                            logForm.subject = RLMSubject.find(withID: subjectId)
                            // set server "date" title. (note: not really lastUpdated, but it's all we got)
                            logForm.serverLastUpdated = log.date
                            // mark as published
                            logForm.publishState = .published

                            // sync down and save any attached image files
                            if !log.files.isEmpty {
                                let files = log.files
                                let photoRows = logForm.rows.compactMap({ $0.photo })

                                for row in photoRows {
                                    guard let file = files.first(where: { $0.id == row.id }),
                                        let url = URL(string: file.fileUrl) else {
                                            continue
                                    }
                                    do {
                                        _ = try storage.saveRemoteFile(url, name: row.id, type: "jpg")
                                    } catch {
                                        DDLogError("Failed to save image: \(url)")
                                    }
                                }
                            }

                            subjectLogForms.append(logForm)
                        }

                        // Update DB with new data.
                        RLMLogForm.createOrUpdateAll(with: subjectLogForms)

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


    func syncUPsubjectLogs(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing up 🔺 subject logs")

        // Collect any `RLMLogForm` objects that have their publish state set to `publishing`.
        let allFormLogsForPublishing = RLMLogForm.findAllToSync()

        DDLogVerbose("Daily log form objects to sync up = \(allFormLogsForPublishing.count)")
        notifySyncStateChanged(message: "\(allFormLogsForPublishing.count) daily log forms remaining to sync up ↑")

        if allFormLogsForPublishing.count <= 0 {
            DDLogDebug("⬆️ UP syncComplete!")
            syncStates[syncKey] = .complete
            syncCompletion(nil)
            return
        }

        let form = allFormLogsForPublishing.first!.detached()   // .detached() makes it more thread-safe

        let imageStorageService = DocumentService()
        let request = LogFormAPIModel(form: form, storage: imageStorageService)

        SubjectsAPIService.publishDailyLog(log: request) { [weak self] result in
            switch result {
            case .success(let response):
                DDLogVerbose("success")
                //  update serverDate
                if let form = RLMLogForm.find(withID: response.id) {
                    RLMLogForm.writeTransaction {
                        form.serverLastUpdated = response.logForm.serverLastUpdated
                        form.publishState = .published
                    }
                }

                DDLogDebug("⬆️ UP syncComplete!  form.id = \(form.id)")
                self?.syncUPsubjectLogs(syncCompletion)    // recurse for anymore

            case .failure(let error):
                self?.syncStates[syncKey] = .complete
                DDLogError("\(error)")
                syncCompletion(error)
            }
        }

    }

}
