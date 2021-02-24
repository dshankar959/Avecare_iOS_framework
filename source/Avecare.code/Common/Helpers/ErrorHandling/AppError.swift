// Custom Error type
// https://stackoverflow.com/a/44563062/7599
//
import Foundation



struct AppError: Error {
    var title: String = ""
    var userInfo: String = ""
    var code: String = ""
    var type: Any = ""
}


// The 'errorDescription' is the only part that actually comes generically with 'Error'
extension AppError: LocalizedError {
    // This is actually part of LocalizedError
    var errorDescription: String? {
        return NSLocalizedString(userInfo, comment: "")
    }
}


extension Error {
    var errorTitle: String {
        if type(of: self) == NSError.self {
            return (self as NSError).domain
        }

        return (self as! AppError).title
    }

    var errorCode: String {
        if type(of: self) == NSError.self {
            let userInfo = (self as NSError).userInfo
            if let statusCode = userInfo["statusCode"] as? NSNumber {
                return statusCode.stringValue
            } else {
                return "unknown"
            }
        }

        return (self as! AppError).code
    }

}
