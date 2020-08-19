import CocoaLumberjack



extension SyncEngine {

    func syncDOWNunitDailyTaskChecklists(_ syncCompletion: @escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 Published Checklists")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor,
            let unitId = RLMSupervisor.details?.primaryUnitId {

            let request = UnitAPIService.DailyTaskFormsRequest(unitId: unitId)

            UnitAPIService.getPublishedDailyTaskForms(request: request) { [weak self] result in
                switch result {
                case .success(let publishedDailyTaskForms):

                    if !publishedDailyTaskForms.isEmpty, let publishedForm = publishedDailyTaskForms.first {    // server-side
                        publishedForm.clientLastUpdated = publishedForm.serverLastUpdated
                        publishedForm.publishState = PublishState.published

                        // Check local DB.
                        let allDailyChecklists = RLMDailyTaskForm.findAll()
                        let sortedDailyChecklists = RLMDailyTaskForm.sortObjectsByLastUpdated(order: .orderedDescending, allDailyChecklists)
                        let publishedDailyChecklists = sortedDailyChecklists.filter { $0.rawPublishState == PublishState.published.rawValue }

                        if allDailyChecklists.isEmpty {
                            // fresh install
                            RLMDailyTaskForm.createOrUpdateAll(with: [publishedForm])
                        } else if let localLastPublished = publishedDailyChecklists.first?.serverLastUpdated,
                            let serverLastPublished = publishedDailyTaskForms.first?.serverLastUpdated {
                            // Current day completed on the server, but missing locally from published versions.
                            if localLastPublished != serverLastPublished {
                                RLMDailyTaskForm.createOrUpdateAll(with: [publishedForm])
                            }
                        } else if let localLastSaved = sortedDailyChecklists.first?.clientLastUpdated,
                            let serverLastPublished = publishedDailyTaskForms.first?.serverLastUpdated {
                            // Current day completed on the server, but missing locally from unpublished versions.
                            if Date.yearMonthDayFormatter.string(from: localLastSaved) == Date.yearMonthDayFormatter.string(from: serverLastPublished) {
                                sortedDailyChecklists.first?.clean()
                                RLMDailyTaskForm.createOrUpdateAll(with: [publishedForm])
                            }
                        }

                    }

                    DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMDailyTaskForm.className())\' items in DB: \(RLMDailyTaskForm.findAll().count)")

                    self?.syncStates[syncKey] = .complete
                    syncCompletion(nil)
                case .failure(let error):
                    self?.syncStates[syncKey] = .complete
                    syncCompletion(error)
                }
            }
        } else {
            DDLogWarn("Nothing to sync down here for Guardian")
            self.syncStates[syncKey] = .complete
            syncCompletion(nil)
        }
    }


    // RLMDailyTaskForm
    func syncUPDailyTaskChecklist(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing up 🔺 Daily Checklist")

        // Collect any `Checklist` objects that have their publish state set to `publishing`.
        let allDailyTasksForPublishing: [RLMDailyTaskForm]

        allDailyTasksForPublishing = RLMDailyTaskForm.findAllToSync(detached: true)

        DDLogVerbose("Daily Task list objects to sync up = \(allDailyTasksForPublishing.count)")
        notifySyncStateChanged(message: "\(allDailyTasksForPublishing.count) daily Task lists remaining to sync up ↑")

        if allDailyTasksForPublishing.count <= 0 {
            DDLogDebug("⬆️ UP syncComplete!")
            syncStates[syncKey] = .complete
            syncCompletion(nil)
            return
        }

        let dailyTaskForm = allDailyTasksForPublishing.first!

        if let unitId = RLMSupervisor.details?.primaryUnitId {

            NotificationsAPIService.publishDailyTaskForm(unitId: unitId, data: dailyTaskForm, completion: { [weak self] result in
                switch result {
                case .success(let publishedDailyTaskForm):
                    publishedDailyTaskForm.publishState = .published
                    DDLogDebug("⬆️ UP syncComplete!  dailyTaskForm.id = \(publishedDailyTaskForm.id)")
                    RLMDailyTaskForm.createOrUpdateAll(with: [publishedDailyTaskForm])

                    self?.syncUPDailyTaskChecklist(syncCompletion)    // recurse for anymore

                case .failure(let error):
                    self?.syncStates[syncKey] = .complete
                    DDLogError("\(error)")
                    syncCompletion(error)
                }
            })
        } else {
            syncStates[syncKey] = .complete
            let error = AppError(title: "🤔", userInfo: "Missing unit id", code: "🤔", type: "")    // should never happen.
            syncCompletion(error)
            return
        }
    }

}
