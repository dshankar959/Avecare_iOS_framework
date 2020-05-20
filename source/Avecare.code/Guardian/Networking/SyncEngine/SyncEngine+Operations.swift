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
                                        self.syncOrganizationDetails() { error in
                                            DDLogVerbose("syncOrganizationDetails ♓️ closure")
                                            if let error = error { syncCompletion(error) } else {
                                                self.syncUnitSupervisors() { error in
                                                    DDLogVerbose("syncUnitSupervisors ♓️ closure")
                                                    if let error = error { syncCompletion(error) } else {
                                                        self.syncDOWNUnitStories { error in
                                                            DDLogVerbose("syncDOWNUnitStories ♓️ closure")
                                                            self.syncDOWNSubjectLogs { error in
                                                                DDLogVerbose("syncDOWNSubjectLogs ♓️ closure")
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

    } // syncOperations(..)


    func isSyncUpRequired() -> Bool {
        /// ...
        false
    }


}
