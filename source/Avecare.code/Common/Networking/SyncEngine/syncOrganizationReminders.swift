import CocoaLumberjack



extension SyncEngine {

    func syncDOWNorganizationReminders(_ syncCompletion: @escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing down 🔻 organization reminders")

        // Sync down from server and update our local DB.
        if appSession.userProfile.isSupervisor {
            if let unitId = RLMSupervisor.details?.primaryUnitId,
                let unitDetails = RLMUnit.details(for: unitId),
                let institutionDetails = RLMInstitution.details(for: unitDetails.institutionId) {
                OrganizationsAPIService.getAvailableReminders(organizationId: institutionDetails.organizationId) { [weak self] result in
                    switch result {
                    case .success(let reminders):
                        // Update with new data.
                        RLMReminderOption.createOrUpdateAll(with: reminders)
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMReminderOption.className())\' items in DB: \(RLMReminderOption.findAll().count)")
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(nil)
                    case .failure(let error):
                        self?.syncStates[syncKey] = .complete
                        syncCompletion(error)
                    }
                }
            }
        } else {
            if let organizationId = RLMOrganization.findAll().first?.id {
                OrganizationsAPIService.getAvailableReminders(organizationId: organizationId) { [weak self] result in
                    switch result {
                    case .success(let reminders):
                        // Update with new data.
                        RLMReminderOption.createOrUpdateAll(with: reminders)
                        DDLogDebug("⬇️ DOWN syncComplete!  Total \'\(RLMReminderOption.className())\' items in DB: \(RLMReminderOption.findAll().count)")
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


    func syncUPorganizationReminders(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        notifySyncStateChanged(message: "Syncing up 🔺 Organization reminders")

        // Collect any `reminder` objects that have their publish state set to `publishing`.
        let allRemindersForPublishing = RLMReminder.findAllToSync()

        DDLogVerbose("Reminder objects to sync up = \(allRemindersForPublishing.count)")
        notifySyncStateChanged(message: "\(allRemindersForPublishing.count) reminders remaining to sync up ↑")

        if allRemindersForPublishing.count <= 0 {
            DDLogDebug("⬆️ UP syncComplete!")
            syncStates[syncKey] = .complete
            syncCompletion(nil)
            return
        }

        NotificationsAPIService.publishReminders(data: allRemindersForPublishing, completion: { [weak self] result in
            switch result {
            case .success(let publishedReminders):
                for reminder in publishedReminders {
                    reminder.publishState = .published
                    DDLogDebug("⬆️ UP syncComplete!  reminder.id = \(reminder.id)")
                }
                RLMReminder.createOrUpdateAll(with: publishedReminders, update: true)
                self?.syncUPorganizationReminders(syncCompletion)    // recurse for anymore
            case .failure(let error):
                self?.syncStates[syncKey] = .complete
                DDLogError("\(error)")
                syncCompletion(error)
            }
        })
    }

}
