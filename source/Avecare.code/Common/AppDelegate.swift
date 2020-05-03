import UIKit
import CocoaLumberjack
import IHProgressHUD
import DeviceKit
import Reachability
import Firebase



@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate, IndicatorProtocol {
    var window: UIWindow?

    // MARK: - AppDelegate Singleton GLOBALS

    // https://stackoverflow.com/questions/45832155/how-do-i-refactor-my-code-to-call-appdelegate-on-the-main-thread/45833540#45833540
    static var _applicationDelegate: AppDelegate!   // treat as #internal.  Use Global: `appDelegate` instead to read.  Underscore to write.

    let reachability = { () -> Reachability in
        do {
            return try Reachability(hostname: ServerURLs.reachability.description)
        } catch let error {
            DDLogError("Reachability error: \(error)")
            fatalError("Reachability error: \(error)")
        }

    }()

    var _isDataConnection: Bool = false     // treat as #internal.  Use Global: `isDataConnection` instead to read.  Underscore to write.

    let _device: Device = {                 // treat as #internal.  Use Global: `hardwareDevice` instead to read.  Underscore to write.
        return Device.current
    }()

    var _session: Session = Session()       // treat as #internal.  Use Global: `appSession` instead to read.  Underscore to write.

    var _loggerDirectory: URL = URL(fileURLWithPath: "")    // location of all log files.
    var _appSettings: AppSettings = AppSettings()

//    var _isShuttingDown: Bool = false


    // MARK: -

    override init() {
        IHProgressHUD.set(defaultMaskType: .clear)
        IHProgressHUD.setHUD(backgroundColor: #colorLiteral(red: 0.7610064149, green: 0.759601295, blue: 0.8178459406, alpha: 1))
        //FIXME:
        //IHProgressHUD.set(foregroundColor: Theme.slateGray.mainColor)

        super.init()
        AppDelegate._applicationDelegate = self

        setupLoggingFramework()
        DDLogInfo("")

        #if GUARDIAN
            DDLogInfo("GUARDIAN.  [eg. \"Parent\", \"Pet Owner\", etc.]")
        #elseif SUPERVISOR
            DDLogInfo("SUPERVISOR.  [eg. \"Educator\", \"Animal Trainer\", etc.]")
        #endif

//        if appSettings.isTesting {
//            DDLogError("~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~")
//            DDLogError(" ATTENTION!  SYSTEM UNDER TEST -")
//            DDLogError(" ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~ ⚠️ ~  ~\n")
//        }

        // Programmatically enabling CFNetwork diagnostic logging:
        // https://stackoverflow.com/a/48971763/7599
//        setenv("CFNETWORK_DIAGNOSTICS", "2", 1)
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DDLogDebug(appNameVersionAndBuildDateString())
        DDLogDebug("server url: \(appSettings.serverURLstring)")

        UITabBar.appearance().unselectedItemTintColor = R.color.darkText()

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            DDLogError("could not start reachability notifier ⁉️")
        }

        #if DEBUG || targetEnvironment(simulator)
            DDLogDebug("⚠️  #DEBUG build ❕ Crashlytics DISABLED. ❕")
        #else
            DDLogDebug("⚠️  #RELEASE buid❕ Crashlytics ENABLED.  ⚠️")
            FirebaseApp.configure()
        #endif

        DDLogInfo("")
        return true
    }

    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability

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
    }


    func applicationWillTerminate(_ application: UIApplication) {
        DDLogDebug("")
    }


}
