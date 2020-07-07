import Foundation
import CocoaLumberjack
import Moya

// MARK: - constants

struct HTTPerror {
    static let code_410 = "410" // GONE.  Indicates that the resource requested is no longer available and will not be available again.
}

private struct Defaults {
    static let contactSupport = NSLocalizedString("error_default_contact_support", comment: "")
    static let contactAdmin = NSLocalizedString("error_default_contact_admin", comment: "")
    static let tryAgain = NSLocalizedString("error_default_try_again", comment: "")
}

enum RealmError {
    case invalidRowObject

    var message: AppError {
        switch self {
        case .invalidRowObject:
            return AppError(title: NSLocalizedString("error_realm_invalid_row_object_title", comment: ""),
                    userInfo: NSLocalizedString("error_realm_invalid_row_object_userinfo", comment: ""),
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
            return AppError(title: NSLocalizedString("error_auth_empty_credentials_title", comment: ""),
                            userInfo: NSLocalizedString("error_auth_empty_credentials_userinfo", comment: "") +
                                Defaults.tryAgain,
                            code: "AuthError.emptyCredentials",
                            type: self)

        case .expiredSession:
            return AppError(title: NSLocalizedString("error_auth_expired_session_title", comment: ""),
                            userInfo: NSLocalizedString("error_auth_expired_session_userinfo", comment: "") +
                                Defaults.tryAgain,
                            code: "AuthError.expiredSession",
                            type: self)

        case .userNotFound:
            return AppError(title: NSLocalizedString("error_auth_user_not_found_title", comment: ""),
                            userInfo: NSLocalizedString("error_auth_user_not_found_userinfo", comment: "") +
                                Defaults.contactAdmin,
                            code: "AuthError.userNotFound",
                            type: self)
        case .unitNotFound:
            return AppError(title: NSLocalizedString("error_auth_unit_not_found_title", comment: ""),
                    userInfo: NSLocalizedString("error_auth_unit_not_found_userinfo", comment: ""),
                    code: "AuthError.unitNotFound",
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
            return AppError(title: NSLocalizedString("error_json_failed_map_data_title", comment: ""),
                            userInfo: NSLocalizedString("error_json_failed_map_data_userinfo", comment: "") +
                                Defaults.contactSupport,
                            code: "JSONError.failedToMapData",
                            type: self)
        case .invalidRowTypeId:
            return AppError(title: NSLocalizedString("error_json_invalid_row_type_id_title", comment: ""),
                    userInfo: NSLocalizedString("error_json_invalid_row_type_id_userinfo", comment: ""),
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
                            userInfo: NSLocalizedString("error_network_http_code_userinfo", comment: "") +
                                "\(statusCode).\n" + Defaults.tryAgain,
                            code: "\(statusCode)",
                            type: self)

        case .HTTP(let description, let domain):
            return AppError(title: "⚠️",
                            userInfo: description,
                            code: domain,
                            type: self)

        case .NetworkConnectionLost:
            return AppError(title: NSLocalizedString("error_network_connection_lost_title", comment: ""),
                            userInfo: NSLocalizedString("error_network_connection_lost_userinfo", comment: ""),
                            code: "0",  // unreachable
                type: self)

        }
    }
}

enum FileError {
    case fileNotFound

    var message: AppError {
        switch self {
        case .fileNotFound:
            return AppError(title: NSLocalizedString("error_file_not_found_title", comment: ""),
                            userInfo: NSLocalizedString("error_file_not_found_userinfo", comment: ""),
                            code: "FileError.fileNotFound", type: self)
        }
    }
}

enum FileTransferError {
    case emptyFileParameter
    case missingFile

    var message: AppError {
        switch self {
        case .missingFile:
            return AppError(title: NSLocalizedString("error_file_transfer_missing_title", comment: ""),
                            userInfo: NSLocalizedString("error_file_transfer_missing_userinfo", comment: "") +
                                Defaults.contactAdmin,
                            code: "FileTransferError.missingFile",
                            type: self)
        case .emptyFileParameter:
            return AppError(title: NSLocalizedString("error_file_transfer_empty_file_parameter_title", comment: ""),
                            userInfo: NSLocalizedString("error_file_transfer_empty_file_parameter_userinfo", comment: ""),
                            code: "FileTransferError.emptyFileParameter",
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

        if response?.statusCode == 401 {
            NotificationCenter.default.post(name: .didReceiveUnauthorizedError, object: nil)
        }

        appError = NetworkError.HTTP(description: description, domain: "\(response?.statusCode ?? 0)").message
    }

    // fyi
    if appError.code == HTTPerror.code_410 {
        DDLogError("⚠️  .code_410")
    }

    return appError
}


public extension Notification.Name {
    static let didReceiveUnauthorizedError = Notification.Name("didReceiveUnauthorizedError")
}
