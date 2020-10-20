import UIKit
import CocoaLumberjack
import Connectivity



extension AppDelegate {

    func updateConnectionStatus(_ status: Connectivity.Status) {

        /// TESTING!
        /// Fake losing internet connection.
//        #if DEBUG || targetEnvironment(simulator)
//            self._isDataConnection = false
//            DDLogDebug("⚠️ [FAKE] 📵  Network not reachable. ⚠️")
//            return
//        #endif

        switch status {
        case .connected:
            DDLogDebug(" 📡  Reachable.  ✅")
            self._isDataConnection = true

        case .connectedViaWiFi:
            DDLogDebug(" 📶  Reachable via WiFi")
            self._isDataConnection = true

        case .connectedViaCellular:
            DDLogDebug(" 📲  Reachable via Cellular")
            self._isDataConnection = true

        case .connectedViaWiFiWithoutInternet:
            DDLogDebug(" 🚫  Network not reachable  (WiFiWithoutInternet)")
            self._isDataConnection = false

        case .connectedViaCellularWithoutInternet:
            DDLogDebug(" 🚫  Network not reachable  (CellularWithoutInternet)")
            self._isDataConnection = false

        case .notConnected:
            DDLogDebug(" 📵  Network not reachable")
            self._isDataConnection = false

        case .determining:
            DDLogDebug(" 🤔 ...determining ... if network is reachable.")
        }

    }

}
