import Foundation
import CocoaLumberjack
import KeychainAccess



struct UserKeychainService {
    private static let myKeychain = Keychain(service: Bundle.main.bundleId)
    private static let kUsersKey = "allUsers"

    // Add/update user profiles list in keychain
    static func saveUserProfile(_ user: UserProfile) {
        DDLogInfo("")

        if user.isEmpty() {
            DDLogError("Empty user profile.")
            return
        }

        var allUsers = UserKeychainService.getAllUserProfiles()
        let key = user.email
        allUsers[key] = user    // add/update dictionary

        do {
            // Encode dictionary as JSON `Data`
            guard let encodedJSONdata = try? JSONEncoder().encode(allUsers) else {
                DDLogError("Failed to encode '\(UserKeychainService.kUsersKey)' object into 'Data'")
                DDLogError("allUsers = \(allUsers)")
                return
            }

            // Save encodedJSONdata into Keychain
            try UserKeychainService.myKeychain.set(encodedJSONdata, key: UserKeychainService.kUsersKey)

        } catch let error {
            DDLogError("An error occured: \(error)")
        }
    }

    // Get full user profiles list from keychain
    static func getAllUserProfiles() -> [String: UserProfile] {
        do {
            guard let encodedJSONdata = try myKeychain.getData(kUsersKey) else {
                DDLogError("Failed to read '\(kUsersKey)' object from keychain")
                return [:]
            }

            // Convert JSON Data back to Dictionary
            guard let users = try? JSONDecoder().decode([String: UserProfile].self, from: encodedJSONdata) as [String: UserProfile] else {
                DDLogError("Failed to decode '\(kUsersKey)' object")
                return [:]
            }

            return users

        } catch let error {
            DDLogError("An error occured: \(error)")
            return [:]
        }
    }

    static func getUserProfile(with email: String) -> UserProfile? {
        let userProfiles = UserKeychainService.getAllUserProfiles()

        if let user = userProfiles[email] {
            return user
        } else {
            return nil
        }
    }

    static func getSingleUserProfileIfPresent() -> UserProfile? {
        let userProfiles = UserKeychainService.getAllUserProfiles()

        if userProfiles.count == 1 {
            return userProfiles.values.first
        } else {
            return nil
        }
    }

    // Since this is possibly a shared iOS device, return the user count that the app has collected.
    static func totalUsers() -> Int {
        let userProfiles = UserKeychainService.getAllUserProfiles()
//        DDLogVerbose("App user count = \(userProfiles.count)")
        return userProfiles.count
    }

    // MARK: - #debugging

    static func dumpAllUserProfilesInKeychain() {
        let userProfiles = UserKeychainService.getAllUserProfiles()

        for (index, item) in userProfiles.enumerated() {
            let profile = item.value
            DDLogVerbose("profile[\(index)]: \(profile.email)")
        }
    }

    static func dumpKeychain() {
        // Raw dump of all items in keychain.
        let items = Keychain(service: Bundle.main.bundleId).allItems()
        for item in items {
            dump(item)
        }
    }

}
