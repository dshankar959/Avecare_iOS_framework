import CocoaLumberjack



extension SyncEngine {

    func syncOperations(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
                self.syncDOWNsubjects() { error in
                    DDLogVerbose("syncDOWNsubjects ♓️ closure")
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
                                                self.syncDOWNorganizationActivities { error in
                                                    DDLogVerbose("syncDOWNorganizationActivities ♓️ closure")
                                                    if let error = error { syncCompletion(error) } else {
                                                        self.syncDOWNorganizationInjuries { error in
                                                            DDLogVerbose("syncDOWNorganizationInjuries ♓️ closure")
                                                            if let error = error { syncCompletion(error) } else {
                                                                self.syncDOWNorganizationReminders { error in
                                                                    DDLogVerbose("syncDOWNorganizationReminders ♓️ closure")
                                                                    if let error = error { syncCompletion(error) } else {
                                                                        self.syncDOWNunitSupervisors() { error in
                                                                            DDLogVerbose("syncDOWNunitSupervisors ♓️ closure")
                                                                            if let error = error { syncCompletion(error) } else {
                                                                                self.syncDOWNunitStories { error in
                                                                                    DDLogVerbose("syncDOWNunitStories ♓️ closure")
                                                                                    self.syncDOWNsubjectLogs { error in
                                                                                        DDLogVerbose("syncDOWNsubjectLogs ♓️ closure")
                                                                                        syncCompletion(error)
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

    } // syncOperations(..)


    func isSyncUpRequired() -> Bool {
        /// ...
        false
    }


}
