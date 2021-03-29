import UIKit
import CocoaLumberjack
import UserNotifications


#if GUARDIAN

extension Notification.Name {
    static let didReceivePushNotification = Notification.Name("didReceivePushNotification")
}


extension AppDelegate {

    func requestAuthorizationForPushNotifications() {
        DDLogInfo("")

        let userNotificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        userNotificationCenter.requestAuthorization(options: options) { (granted, error) in
            if granted {
                DDLogVerbose("Permission granted.  \(granted)")
                // Check notification settings.
                // This is important because the user can, at any time, go into the Settings app and change their notification permissions.
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else { return }

                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            } else if let error = error {
                DDLogError("\(error)")
//                let appError = AppError(title: error.errorTitle, userInfo: error.localizedDescription, code: error.errorCode, type: "")
//                self.showErrorAlert(appError)
                return
            }
        }
    }


    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        DDLogInfo("\(userInfo)")

        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            DDLogError("")
            completionHandler(.failed)
            return
        }

        DDLogInfo("\(aps)")
    }


    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        DDLogInfo("")

        let token = deviceToken.hexadecimalString()
        DDLogDebug("Remote Notification Token: \(token)")
/*
        let deviceInfo: Parameters = [DeviceRequestKeys.deviceType.rawValue: "ios",
                                      DeviceRequestKeys.token.rawValue: token]
        let parameters: Parameters = [DeviceRequestKeys.device.rawValue: deviceInfo]
        let endpoint = APIEndpoint.devices.rawValue

        APIManager.sharedInstance.jsonPostToObject(
            endpoint,
            parameters: parameters,
            authorized: true,
            for: User.current,
            success: { (device: Device) in
                UserDefaults.standard.set(device.id, forKey: UserDefaultsKey.currentUserDeviceId.rawValue)
                DDLogDebug("Remote Notification Token - Registered \(token)")

                #if QA_BUILD
                    UserDefaults.standard.set(token, forKey: UserDefaultsKey.kPushNotificationTokenkey.rawValue)
                #endif
            },
            failure: { error in
                // Do not surface the error to the user because there is nothing they can do.
                // The registration will retry at a later date.
                DDLogError("Remote Notification Token - Registration Failed \(error)")
            }
        )
*/
    }


    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DDLogError("\(error)")

        #if !targetEnvironment(simulator)
        let appError = AppError(title: error.errorTitle, userInfo: error.localizedDescription, code: error.errorCode, type: "")
        self.showErrorAlert(appError)
        #endif
    }

}


extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        DDLogInfo("")

        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            let userInfo = response.notification.request.content.userInfo
            DDLogVerbose("Received Notification Payload: \(userInfo)")

            NotificationCenter.default.post(name: .didReceivePushNotification,
                                            object: nil,
                                            userInfo: ["misc": ""])


/*
            // Prevent handling of notifications intended for users
            // other than the current user. This minimizes the effects
            // of an edge case in which multiple users may sign in on
            // the same device, one after the other, and receive
            // notifications intended for the previous user.
            guard
                let notificationUserId = userInfo[NotificationResponseKeys.userId.rawValue] as? Int,
                let userId = User.current?.id,
                notificationUserId == userId
            else {
                break
            }

            // Optionally navigate to the tab specified in the
            // notification payload, if provided.
            let modelType = userInfo[NotificationResponseKeys.model.rawValue] as? String
            let modelID = userInfo[NotificationResponseKeys.modelID.rawValue] as? Int
            let commentID = userInfo[NotificationResponseKeys.commentID.rawValue] as? Int

            let deepLink = DeepLink(user_id: User.current!.id,
                                    model: modelType,
                                    model_id: modelID,
                                    comment_id: commentID)

            let tab = tabBarItemFor(modelType ?? "Post")

            self.navigate(to: tab) {
                NotificationCenter.default.post(name: .didReceivePushNotification,
                                                object: nil,
                                                userInfo: ["TabBarItemType": tab,
                                                           "DeepLinkInfo": deepLink])
            }
*/
        default:
            break
        }

        completionHandler()
    }


    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        DDLogInfo("")
        completionHandler([.alert, .sound, .badge])
    }

}

#endif
