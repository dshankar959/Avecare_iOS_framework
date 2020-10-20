import UIKit
import CocoaLumberjack
import IHProgressHUD
import DeviceKit
import Connectivity
import Kingfisher



@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate, IndicatorProtocol {
    // MARK: - Singleton GLOBALS

    var window: UIWindow?

    // https://stackoverflow.com/questions/45832155/how-do-i-refactor-my-code-to-call-appdelegate-on-the-main-thread/45833540#45833540
    static var _applicationDelegate: AppDelegate!   // treat as #internal.  Use Global: `appDelegate` instead to read.  Underscore to write.

    let connectivity: Connectivity = Connectivity()

    var _isDataConnection: Bool = false     // treat as #internal.  Use Global: `isDataConnection` instead to read.  Underscore to write.

    let _device: Device = {                 // treat as #internal.  Use Global: `hardwareDevice` instead to read.  Underscore to write.
        return Device.current
    }()

    var _session: Session = Session()       // treat as #internal.  Use Global: `appSession` instead to read.  Underscore to write.
    var _syncEngine = SyncEngine()          // treat as #internal.  Use Global: `syncEngine` instead to read.  Underscore to write.

    var _loggerDirectory: URL = URL(fileURLWithPath: "")    // location of all log files.
    var _appSettings: AppSettings = AppSettings()

    var _selectedSubjectId: String? = nil



    // MARK: -
    override init() {
        IHProgressHUD.set(defaultMaskType: .clear)
        IHProgressHUD.setHUD(backgroundColor: #colorLiteral(red: 0.7610064149, green: 0.759601295, blue: 0.8178459406, alpha: 1))

        super.init()
        AppDelegate._applicationDelegate = self

        setupLoggingFramework()
        DDLogInfo("")

        setupSentrySDK()

        // Kingfisher disk image cache
        ImageCache.default.diskStorage.config.sizeLimit = 100 * 1024 //bytes

        #if GUARDIAN
            DDLogInfo("GUARDIAN.  [eg. \"Parent\", \"Pet Owner\", etc.]")
        #elseif SUPERVISOR
            DDLogInfo("SUPERVISOR.  [eg. \"Educator\", \"Animal Trainer\", etc.]")
        #endif

        if appSettings.isTesting {
            DDLogError("~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~")
            DDLogError(" ATTENTION!  SYSTEM UNDER TEST -")
            DDLogError("~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~\n")
        }

        // Programmatically enabling CFNetwork diagnostic logging:
        // https://stackoverflow.com/a/48971763/7599
//        setenv("CFNETWORK_DIAGNOSTICS", "2", 1)

    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DDLogDebug(appNameVersionAndBuildDateString())
        DDLogDebug("server url: \(appSettings.serverURLstring)")

        // Re-construct any previous existing session if the user didn't sign-out.
        if let lastUsername = appSettings.lastUsername,
            let userProfile = UserKeychainService.getUserProfile(with: lastUsername),
            let currentToken = UserKeychainService.getCurrentToken() {
            _session = Session(token: currentToken, userProfile: userProfile)
        }

        UITabBar.appearance().unselectedItemTintColor = R.color.darkText()

        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
            self?.updateConnectionStatus(connectivity.status)
        }

        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
        connectivity.framework = .network
        connectivity.startNotifier()

        DDLogInfo("")
        return true
    }


    func applicationWillResignActive(_ application: UIApplication) {
        DDLogDebug("")
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        DDLogDebug("")
    }


    func applicationWillEnterForeground(_ application: UIApplication) {
        DDLogDebug("")
    }


    func applicationDidBecomeActive(_ application: UIApplication) {
        DDLogDebug("")
        self.window?.isHidden = false

        // Get Available Disk Space  (eg. 96922558464)
        let availableDiskSpace = Double(Device.volumeAvailableCapacityForOpportunisticUsage ?? 0)
//        DDLogVerbose("available disk space = \(formatBytesToSize(bytes: availableDiskSpace))")

        if availableDiskSpace < Double(250_000_000) {  // 250mb
            DDLogVerbose("availableDiskSpace < 250_000_000")

            // remove disk image cache
            ImageCache.default.clearDiskCache()

            self.popupAlert(title: "⚠️ Storage Almost Full",
                            message: "Clear some disk space to avoid any app interruption.",
                            actionTitles: ["Got it!"],
                            actionStyles: [.default],
                            actions: [ { action1 in
                                }, nil])
            return
        }

    }


    func applicationWillTerminate(_ application: UIApplication) {
        DDLogDebug("")
    }


}
