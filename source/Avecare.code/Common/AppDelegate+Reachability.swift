import UIKit
import CocoaLumberjack
import Reachability



extension AppDelegate {

    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability

        /// TESTING!
        /// Fake losing internet connection.
//        #if DEBUG || targetEnvironment(simulator)
//            self._isDataConnection = false
//            DDLogDebug("⚠️ [FAKE] 📵  Network not reachable. ⚠️")
//            return
//        #endif


        switch reachability.connection {
        case .wifi:
            DDLogDebug(" 📶  Reachable via WiFi")
            self._isDataConnection = true
/*
            if !appSession.isSignedIn() || appSession.token.isFake {
                // If we just have a fake token, because we were offline, then try to auto-signIn.
                autoSignIn()
            }
*/
        case .cellular:
            DDLogDebug(" 📲  Reachable via Cellular")
            self._isDataConnection = true
/*
            if !appSession.isSignedIn() || appSession.token.isFake {
                // If we just have a fake token, because we were offline, then try to auto-signIn.
                autoSignIn()
            }
*/
        case .none,
            .unavailable:
            DDLogDebug(" 📵  Network not reachable")
            self._isDataConnection = false
        }
    }

}
