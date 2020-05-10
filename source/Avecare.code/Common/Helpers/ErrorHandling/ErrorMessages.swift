import Foundation
import CocoaLumberjack
import Moya

// MARK: - constants

struct HTTPerror {
    static let code_410 = "410" // GONE.  Indicates that the resource requested is no longer available and will not be available again.
}

private struct Defaults {
    static let contactSupport = "Please contact support for further assistance."
    static let contactAdmin = "Please contact the system administrator."
    static let tryAgain = "Please try again."
}

enum RealmError {
    case invalidRowObject

    var message: AppError {
        switch self {
        case .invalidRowObject:
            return AppError(title: "🆘 Realm object initialization failure ⁉️",
                    userInfo: "Invalid object class was used in ctor",
                    code: "RealmError.invalidRowObject",
                    type: self)
        }
    }
}

enum AuthError {
    case emptyCredentials
    case expiredSession
    //    case InvalidCredentials
    //    case PermissionDenied
    //    case InvalidDevice
    //    case UserAccountInactive
    //    case UserAccountActivationRequired
    //    case UserAccountExpired
    //    case UserMustChangePassword
    case userNotFound
    //    case UserAccountLocked
    case unitNotFound

    var message: AppError {
        switch self {
        case .emptyCredentials:
            return AppError(title: "oops!",
                            userInfo: "Email or Password cannot be empty\n"+Defaults.tryAgain,
                            code: "AuthError.emptyCredentials",
                            type: self)

        case .expiredSession:
            return AppError(title: "⚠️ Expired Session",
                            userInfo: "Sign-in required.\n"+Defaults.tryAgain,
                            code: "AuthError.expiredSession",
                            type: self)

        case .userNotFound:
            return AppError(title: "⚠️ User not found",
                            userInfo: "This user has not been registered on this device.\n\n"+Defaults.contactAdmin,
                            code: "userNotFound",
                            type: self)
        case .unitNotFound:
            return AppError(title: "⚠️ Unit details not loaded",
                    userInfo: "Unit details was not loaded.",
                    code: "unitNotFound",
                    type: self)
        }
    }
}

enum JSONError {
    case failedToMapData
    case invalidRowTypeId

    var message: AppError {
        switch self {
        case .failedToMapData:
            return AppError(title: "🆘 Critical JSON Error ⁉️",
                            userInfo: "Terribly sorry about this.\n "+Defaults.contactSupport,
                            code: "JSONError.failedToMapData",
                            type: self)
        case .invalidRowTypeId:
            return AppError(title: "🆘 Critical JSON Error ⁉️",
                    userInfo: "Invalid row type id",
                    code: "JSONError.invalidRowTypeId",
                    type: self)
//        case .details(let info):
//            return AppError(title: "", userInfo: info, code: "")
        }
    }
}

enum NetworkError {
    case HTTPcode(statusCode: Int)
    case HTTP(description: String, domain: String)
    case NetworkConnectionLost

    var message: AppError {
        switch self {
        case .HTTPcode(let statusCode):
            return AppError(title: "⚠️",
                            userInfo: "Server responded with statusCode: \(statusCode).\n "+Defaults.tryAgain,
                            code: "\(statusCode)",
                            type: self)

        case .HTTP(let description, let domain):
            return AppError(title: "⚠️",
                            userInfo: description,
                            code: domain,
                            type: self)

        case .NetworkConnectionLost:
            return AppError(title: "📶 Network",
                            userInfo: "No data connection.",
                            code: "0",  // unreachable
                type: self)

        }
    }
}

enum FileTransferError {
    case emptyFileParameter
    case missingFile

    var message: AppError {
        switch self {
        case .missingFile:
            return AppError(title: "🆘 File Error!",
                            userInfo: "Missing file after transfer completed.\n "+Defaults.contactAdmin,
                            code: "FileTransferError",
                            type: self)
        case .emptyFileParameter:
            return AppError(title: "File Error",
                            userInfo: "Empty file parameter.\n Nothing to do.",
                            code: "emptyFileParameter",
                            type: self)
        }
    }
}

func getAppErrorFromMoya(with error: MoyaError) -> AppError {
    var appError = AppError()

    DDLogError("error = \(error)\n")

    // Handling different error types
    // https://github.com/Moya/Moya/blob/master/docs/Examples/ErrorTypes.md
    switch error {
    case .imageMapping(let response):
        DDLogError(".imageMapping response = \(response)")
        DDLogError(".imageMapping statusCode = \(response.statusCode)")
        appError =  NetworkError.HTTPcode(statusCode: response.statusCode).message

    case .jsonMapping(let response):
        DDLogError(".jsonMapping response = \(response)")
        DDLogError(".jsonMapping statusCode = \(response.statusCode)")
        appError =  NetworkError.HTTPcode(statusCode: response.statusCode).message

    case .statusCode(let response):
        DDLogError(".statusCode response = \(response)")
        DDLogError(".statusCode statusCode = \(response.statusCode)")
        appError =  NetworkError.HTTPcode(statusCode: response.statusCode).message

    case .stringMapping(let response):
        DDLogError(".stringMapping response = \(response)")
        DDLogError(".stringMapping statusCode = \(response.statusCode)")
        appError =  NetworkError.HTTPcode(statusCode: response.statusCode).message

    case .objectMapping(let error, let response):
        // error is DecodingError
        DDLogError(".objectMapping error = \(error)")
        DDLogError(".objectMapping response = \(response)")
        DDLogError(".objectMapping statusCode = \(response.statusCode)")
        appError =  NetworkError.HTTPcode(statusCode: response.statusCode).message

    case .encodableMapping(let error):
        DDLogError(".encodableMapping response = \(error)")

    case .requestMapping(let url):
        DDLogError(".requestMapping url = \(url)")

    case .parameterEncoding(let error):
        DDLogError(".parameterEncoding error = \(error)")

    // Indicates a response failed due to an underlying `Error`.
    case .underlying(let nsError as NSError, let response):
        // now can access NSError error.code or whatever
        // e.g. NSURLErrorTimedOut or NSURLErrorNotConnectedToInternet
        DDLogError(".underlying nsError.code = \(nsError.code)")
        DDLogError(".underlying nsError.domain = \(nsError.domain)")
        DDLogError(".underlying localizedDescription = \(String(describing: error.localizedDescription))")

        var description = error.localizedDescription

        if let resp = response {
            DDLogError(".underlying response = \(resp)")
            if let responseDict = try? JSONSerialization.jsonObject(with: (error.response?.data)!, options: []) as? [String: AnyObject] {
                DDLogError("response Dict = \(responseDict)")
                if let item1 = responseDict.first {
                    if item1.value is NSArray {
                        if let item2 = (item1.value as! NSArray).firstObject {
                            if let value = item2 as? String {
                                description = value
                            }
                        }
                    } else if let value = item1.value as? String {
                        description = value
                    }
                }
            } else {
                // https://github.com/Moya/Moya/issues/1223#issuecomment-322978182
                let responseJSON = try? error.response?.mapJSON()
                if let response = responseJSON {
                    DDLogError("response = \(response)")
                    description = "\(response)"
                }
            }
        }

        appError = NetworkError.HTTP(description: description, domain: "\(response?.statusCode ?? 0)").message
    }

    // fyi
    if appError.code == HTTPerror.code_410 {
        DDLogError("⚠️  .code_410")
    }

    return appError

}
