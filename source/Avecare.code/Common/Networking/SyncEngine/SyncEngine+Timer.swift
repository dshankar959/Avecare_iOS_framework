import CocoaLumberjack



extension SyncEngine {

    func startSyncTimer() {
        DDLogVerbose("")
        syncTimer = Timer.scheduledTimer(timeInterval: SyncConfig.timerInterval,
                                         target: self,
                                         selector: #selector(triggerSync),
                                         userInfo: nil,
                                         repeats: true)
        if syncTimer != nil {
            syncTimer!.tolerance = 2.0
            DDLogVerbose("SyncTimer started.")
        } else {
            DDLogError("SyncTimer failed to start.  🤔")
        }
    }

    @objc func triggerSync() {
        if !syncEngine.isSyncing {
            DDLogVerbose("‼️ -🔄- ‼️")
            syncAll { error in
                DDLogInfo("ℹ️ closure in: \(self)")
                if let error = error {
                    DDLogError(" ❕  \(error)  ❕")
                }
            }
        }
    }


    func stopSyncTimer() {
        DDLogVerbose("")
        if syncTimer != nil {
            syncTimer!.invalidate()
        }
    }


    func fireSyncTimer() {
        if !syncEngine.isSyncing {
            if syncTimer != nil {
                syncTimer!.fire()
            }
        }
    }


    func resetSyncTimer() {
        DDLogVerbose("⏰ - resetSyncTimer")
        stopSyncTimer()
        startSyncTimer()
    }


}
