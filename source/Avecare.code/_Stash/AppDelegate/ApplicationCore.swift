import Foundation
import UIKit

open class ApplicationCore: UIResponder, UIApplicationDelegate {

    open var services: [ApplicationService] = []

    open var window: UIWindow? = UIWindow()

    open func applicationDidFinishLaunching(_ application: UIApplication) {
        services.forEach { $0.applicationDidFinishLaunching?(application) }
    }

    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        guard !services.isEmpty else { return true }

        return services.reduce(false) { result, service -> Bool in
            let next = service.application?(application, didFinishLaunchingWithOptions: launchOptions) ?? true
            return result || next
        }
    }

    open func applicationWillResignActive(_ application: UIApplication) {
        services.forEach { $0.applicationWillResignActive?(application) }
    }

    open func applicationDidEnterBackground(_ application: UIApplication) {
        services.forEach { $0.applicationDidEnterBackground?(application) }
    }

    open func applicationWillEnterForeground(_ application: UIApplication) {
        services.forEach { $0.applicationWillEnterForeground?(application) }
    }

    open func applicationDidBecomeActive(_ application: UIApplication) {
        services.forEach { $0.applicationDidBecomeActive?(application) }
    }

    open func applicationWillTerminate(_ application: UIApplication) {
        services.forEach { $0.applicationWillTerminate?(application) }
    }

    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return services.reduce(false) { result, service -> Bool in
            let next = service.application?(app, open: url, options: options) ?? false
            return result || next
        }
    }

    open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        services.forEach { $0.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken) }
    }

    open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        services.forEach { $0.application?(application, didFailToRegisterForRemoteNotificationsWithError: error) }
    }
}
