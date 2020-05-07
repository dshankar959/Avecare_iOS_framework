import CocoaLumberjack



// MARK: -
extension SyncEngine {

    func syncAll(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogVerbose("")

        if !appSettings.enableSyncUp && !appSettings.enableSyncDown {
            DDLogDebug("🔺🔻❌ sync UP/DOWN ⬆️⬇️ disabled.  ❎❎")
            syncCompletion(nil)
            return
        }

        if self.isSyncBlocked {
            syncCompletion(isSyncCancelled ? nil : NetworkError.NetworkConnectionLost.message)
            return
        }

        if !appSession.isSignedIn() || appSession.token.isFake {
            DDLogError("⚠️ Auth required.")
//            appDelegate.autoSignIn() { error in
//                if error != nil {
//                    syncCompletion(AuthError.expiredSession.message)
//                }
//            }
            return
        }

        if self.syncAllStatus == .syncing {
            DDLogDebug("❕  syncAllStatus =🔄= .syncing  ❕")
            closuresToPerformWhenSyncComplete.append { error in
                syncCompletion(error)
            }
            return
        }

        self.syncAllStatus = .syncing
        resetSyncTimer()

        closuresToPerformWhenSyncComplete.append { error in
            syncCompletion(error)
        }

        self.syncDOWNimmutables { error in
            DDLogDebug("⭕️ syncDOWNimmutables ⬇️ complete!  ✅✅")

            if let error = error {
                self.syncAllStatus = .complete

                for completion in self.closuresToPerformWhenSyncComplete {
                    completion(error)
                }
                self.closuresToPerformWhenSyncComplete.removeAll()
                NotificationCenter.default.post(name: .didCompleteSync, object: SyncEngine.self)

            } else { // no error
                self.syncAllStatus = .complete

                for completion in self.closuresToPerformWhenSyncComplete {
                    completion(error)
                }
                self.closuresToPerformWhenSyncComplete.removeAll()
                NotificationCenter.default.post(name: .didCompleteSync, object: SyncEngine.self)



/*
                self.syncUPsignsAndComments { error in
                    DDLogDebug("⭕️ syncUPsignsAndComments ⬆️ complete!  ✅")

                    if let error = error {
                        self.syncAllStatus = .complete

                        for completion in self.closuresToPerformWhenSyncComplete {
                            completion(error)
                        }
                        self.closuresToPerformWhenSyncComplete.removeAll()
                        NotificationCenter.default.post(name: .didCompleteSync, object: SyncEngine.self)

                    } else { // no error

                        self.syncDOWNsignsAndCommentsAndArtwork { error in
                            DDLogDebug("⭕️ syncDOWNsignsAndComments (and optionally artwork) ⬇️ complete!  ✅✅")

                            self.syncAllStatus = .complete

                            for completion in self.closuresToPerformWhenSyncComplete {
                                completion(error)
                            }
                            self.closuresToPerformWhenSyncComplete.removeAll()
                            NotificationCenter.default.post(name: .didCompleteSync, object: SyncEngine.self)
                        }
                    }
                }
*/
            }

        }

    }


    @objc func didCompleteSyncAll(notification: NSNotification) {
        if !syncEngine.isSyncing {
            DDLogVerbose("‼️ sync all complete!")
        }
    }


    func isSyncUpRequired() -> Bool {
//        let syncUpSignAnnotationsCount = self.signAnnotationsDAL.readyToSyncUpCount()
//        let syncUpCommentsCount = self.commentsDAL.readyToSyncUpCount()
//
//        if syncUpSignAnnotationsCount > 0 || syncUpCommentsCount > 0 {
//            DDLogVerbose("SyncUpRequired == true.  syncUpSignAnnotationsCount = \(syncUpSignAnnotationsCount), syncUpCommentsCount = \(syncUpCommentsCount)")
//            return true
//        }
//
//        DDLogVerbose("isSyncUpRequired == false")
//        return false

        false
    }


    func notifySyncStateChanged(message: String) {
        DDLogDebug("\(message)")
        NotificationCenter.default.post(name: .syncStateChanged, object: SyncEngine.self, userInfo: ["message": message])
    }

    // MARK: -
/*
    func syncUPsignsAndComments(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
        DDLogVerbose("")

        if !appSettings.enableSyncUp {
            DDLogDebug("🔺❌ sync UP ⬆️ disabled.  ❎❎")
            syncCompletion(nil)
            return
        }

        if self.isSyncBlocked {
            syncCompletion(isSyncCancelled ? nil : NetworkError.NetworkConnectionLost.message)
            return
        }

        syncUPsignAnnotationsForRemoval() { [unowned self] error in
            DDLogVerbose("syncUPsignAnnotationsForRemoval ♓️ closure")
            if let error = error { syncCompletion(error) } else {
                self.syncUPsignAnnotationsForUpdate() { [unowned self] error in
                    DDLogVerbose("syncUPsignAnnotationsForUpdate ♓️ closure")
                    if let error = error { syncCompletion(error) } else {
                        self.syncUPcommentsForUpdate() { error in
                            DDLogVerbose("syncUPcommentsForUpdate ♓️ closure")
                            syncCompletion(error)
                        }
                    }
                }
            }
        }

    }


    func syncDOWNsignsAndCommentsAndArtwork(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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
        self.syncDOWNsignAnnotations() { error in   // no artwork here.
            DDLogVerbose("syncDOWNsignAnnotations ♓️ closure")
            if let error = error { syncCompletion(error) } else {
                self.syncDOWNcomments() { error in          // includes thumbnails
                    DDLogVerbose("syncDOWNcomments ♓️ closure")
                    if let error = error { syncCompletion(error) } else {

                        if !appSettings.thinClientMode {
                            DDLogVerbose("+++ thick client mode ⚛️")
                            /// +++ thick client mode: starts here +++
                            /// sync all artwork
                            self.syncArtwork() { error in
                                DDLogVerbose("syncArtwork ♓️ closure")
                                if let error = error { syncCompletion(error) } else {
                                    syncCompletion(nil)
                                }
                            }
                        } else {
                            DDLogVerbose("thinClientMode ⚛️")
                            syncCompletion(nil)
                        }

                    }
                }
            }
        }

    }
*/

    // Everything except signs and comments (which can be edited), and artwork (part of signs dependancy).
    func syncDOWNimmutables(_ syncCompletion:@escaping (_ error: AppError?) -> Void) {
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

        self.syncDOWNsupervisorDetails() { error in
            DDLogVerbose("syncDOWNsupervisorDetails ♓️ closure")
            if let error = error { syncCompletion(error) } else {
                self.syncDOWNunitDetails() { error in
                    if let error = error { syncCompletion(error) } else {
                        syncCompletion(nil)
                    }
                }
            }
        }

    }


}
