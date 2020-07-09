import CocoaLumberjack



extension SyncEngine {

    func syncOperations(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogVerbose("")

        syncUPoperations() { error in
            DDLogVerbose("syncUPoperations ♓️ closure")
            if let error = error { syncCompletion(error) } else {
                self.syncDOWNoperations() { error in
                    DDLogVerbose("syncDOWNoperations ♓️ closure")
                    if let error = error { syncCompletion(error) } else {
                        syncCompletion(nil)
                    }
                }
            }
        }

    }

}


extension SyncEngine {

    func syncDOWNoperations(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogVerbose("")

        if !appSettings.enableSyncDown {
            DDLogDebug("🔻❌ sync DOWN ⬇️ disabled.  ❎❎")
            syncCompletion(nil)
            return
        }

        if self.isSyncBlocked {
            syncCompletion(isSyncCancelled ? nil : NetworkError.NetworkConnectionLost.message)
            return
        }

        // Dependancy tree of sync operations.
        self.syncDOWNuserAccountDetails() { error in
            DDLogVerbose("syncDOWNuserAccountDetails ♓️ closure")
            if let error = error { syncCompletion(error) } else {
                self.syncDOWNunitDetails() { error in
                    DDLogVerbose("syncDOWNunitDetails ♓️ closure")
                    if let error = error { syncCompletion(error) } else {
                        self.syncDOWNinstitutionDetails() { error in
                            DDLogVerbose("syncDOWNinstitutionDetails ♓️ closure")
                            if let error = error { syncCompletion(error) } else {
                                self.syncDOWNorganizationDetails() { error in
                                    DDLogVerbose("syncDOWNorganizationDetails ♓️ closure")
                                    if let error = error { syncCompletion(error) } else {
                                        self.syncDOWNorganizationTemplates() { error in
                                            DDLogVerbose("syncDOWNorganizationTemplates ♓️ closure")
                                            if let error = error { syncCompletion(error) } else {
                                                self.syncDOWNorganizationDailyTasks { error in
                                                    DDLogVerbose("syncDOWNorganizationDailyTasks ♓️ closure")
                                                    if let error = error { syncCompletion(error) } else {
                                                        self.syncDOWNorganizationActivities { error in
                                                            DDLogVerbose("syncDOWNorganizationActivities ♓️ closure")
                                                            if let error = error { syncCompletion(error) } else {
                                                                self.syncDOWNorganizationInjuries { error in
                                                                    DDLogVerbose("syncDOWNorganizationInjuries ♓️ closure")
                                                                    if let error = error { syncCompletion(error) } else {
                                                                        self.syncDOWNorganizationReminders { error in
                                                                            DDLogVerbose("syncDOWNorganizationReminders ♓️ closure")
                                                                            if let error = error { syncCompletion(error) } else {
                                                                                self.syncDOWNsubjects() { error in
                                                                                    DDLogVerbose("syncDOWNsubjects ♓️ closure")
                                                                                    if let error = error { syncCompletion(error) } else {
                                                                                        self.syncDOWNsubjectLogs { error in
                                                                                            DDLogVerbose("syncDOWNsubjectLogs ♓️ closure")
                                                                                            if let error = error { syncCompletion(error) } else {
                                                                                                self.syncDOWNunitStories { error in
                                                                                                    DDLogVerbose("syncDOWNunitStories ♓️ closure")
                                                                                                    if let error = error { syncCompletion(error) } else {
                                                                                                        syncCompletion(nil)
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    } // syncDOWNoperations(..)

}



extension SyncEngine {

    func syncUPoperations(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogVerbose("")

        if !appSettings.enableSyncUp {
            DDLogDebug("🔻❌ sync UP ⬆️ disabled.  ❎❎")
            syncCompletion(nil)
            return
        }

        if self.isSyncBlocked {
            syncCompletion(isSyncCancelled ? nil : NetworkError.NetworkConnectionLost.message)
            return
        }

        // Dependancy tree of sync operations.
        self.syncUPunitStories() { error in
            DDLogVerbose("syncUPunitStories ♓️ closure")
            if let error = error { syncCompletion(error) } else {
                self.syncUPsubjectLogs() { error in
                    DDLogVerbose("syncUPsubjectLogs ♓️ closure")
                    if let error = error { syncCompletion(error) } else {
                        self.syncUPorganizationReminders() { error in
                            DDLogVerbose("syncUPorganizationReminders ♓️ closure")
                            if let error = error { syncCompletion(error) } else {
                                self.syncUPinjuries() { error in
                                    DDLogVerbose("syncUPinjuries ♓️ closure")
                                    if let error = error { syncCompletion(error) } else {
                                        self.syncUPOrganizationActivities() { error in
                                            DDLogVerbose("syncUPOrganizationActivities ♓️ closure")
                                            if let error = error { syncCompletion(error) } else {
                                                self.syncUPDailyTaskChecklist() { error in
                                                    DDLogVerbose("syncUPDailyTaskChecklist ♓️ closure")
                                                    if let error = error { syncCompletion(error) } else {
                                                        syncCompletion(nil)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

    } // syncUPoperations(..)


    func isSyncUpRequired() -> Bool {
        /// ...
        false
    }


}
