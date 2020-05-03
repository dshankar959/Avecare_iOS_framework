import Foundation

extension Bundle {

    var appName: String {
        return infoDictionary?["CFBundleName"] as! String
    }

    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as! String
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as! String
    }

    var bundleId: String {
        return bundleIdentifier!
    }

}

func appNameVersionAndBuildDateString() -> String {
    return "\(Bundle.main.appName), v\(Bundle.main.versionNumber) (Build: \(Bundle.main.buildNumber))"
}
