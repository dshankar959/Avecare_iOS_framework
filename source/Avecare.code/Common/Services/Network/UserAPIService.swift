import Foundation
import CocoaLumberjack



struct UserAPIService {

    static func authenticateUserWith(userCreds: UserCredentials,
                                     completion:@escaping (Result<APIToken, AppError>) -> Void) {
        DDLogDebug("")

        // Validate user credentials.
        if userCreds.username.isEmpty || userCreds.password.isEmpty {
            return completion(.failure(AuthError.emptyCredentials.message))
        }

        apiProvider.request(.login(creds: userCreds),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    //  convert JSON response into our 'decodable' model object using Moya's own .map function.
                    //  let rawJSON = try response.mapJSON()
                    //  DDLogDebug("raw JSON: \(rawJSON)\n")
                    let token = try response.map(APIToken.self)
                    DispatchQueue.main.async() {
                        completion(.success(token))
                    }
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    DispatchQueue.main.async() {
                        completion(.failure(JSONError.failedToMapData.message))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async() {
                    completion(.failure(getAppErrorFromMoya(with: error)))
                }
            }
        }
    }


    static func requestOTP(email: String,
                           completion:@escaping (Result<String, AppError>) -> Void) {
        DDLogDebug("")

        // Validate user credentials.
        if email.isEmpty {
            return completion(.failure(AuthError.emptyCredentials.message))
        }

        apiProvider.request(.oneTimePassword(email: email),
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                do {
                    //  convert JSON response into our 'decodable' model object using Moya's own .map function.
                    //  let rawJSON = try response.mapJSON()
                    //  DDLogDebug("raw JSON: \(rawJSON)\n")
                    let message = try response.mapString()
                    DispatchQueue.main.async() {
                        completion(.success(message))
                    }
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    DispatchQueue.main.async() {
                        completion(.failure(JSONError.failedToMapData.message))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async() {
                    completion(.failure(getAppErrorFromMoya(with: error)))
                }
            }
        }
    }


    static func logout(completion:@escaping (Result<Int, AppError>) -> Void) {
        apiProvider.request(.logout,
                            callbackQueue: DispatchQueue.global(qos: .utility)) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async() {
                    completion(.success(response.statusCode))
                }
            case .failure(let error):
                DispatchQueue.main.async() {
                    completion(.failure(getAppErrorFromMoya(with: error)))
                }
            }
        }
    }

}


extension UserAPIService {

    static func submitUserFeedback(for session: Session,
                                   comments: String,
                                   withLogfiles: Bool,
                                   completion:@escaping (_ error: AppError?) -> Void) {
        DDLogVerbose("")

        // Append some additional helpful info.  (fyi)
        let servers = Servers()
        let serverType = servers.valueFromDescription(appSettings.serverURLstring)
        let isCustomType = (serverType == servers.customType) ? true : false

        var userComments = comments + "\n\nPlatform: iOS"

        if isCustomType {
            userComments += "\n\(appNameVersionAndBuildDateString())\nserver: \(appSettings.serverURLstring)"
        } else {
            userComments += "\n\(appNameVersionAndBuildDateString())\nserver: \(serverType)"
        }

        let model = UserFeedbackRequestModel(for: session,
                                             comments: userComments,
                                             includeLogfiles: withLogfiles)

        apiProvider.request(.submitUserFeedback(comments: model)) { result in
            switch result {
            case .success:
                DDLogVerbose("// success")
                FileManager().clearTmpDirectory()
                appDelegate.clearLogFiles()
                DispatchQueue.main.async() {
                    completion(nil)
                }
            case .failure(let error):
                DispatchQueue.main.async() {
                    completion(getAppErrorFromMoya(with: error))
                }
            }
        }
    }

}
