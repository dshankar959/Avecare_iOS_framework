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

        apiProvider.request(.login(creds: userCreds)) { result in
            switch result {
            case .success(let response):
                do {
                    //  convert JSON response into our 'decodable' model object using Moya's own .map function.
                    //  let rawJSON = try response.mapJSON()
                    //  DDLogDebug("raw JSON: \(rawJSON)\n")
                    let token = try response.map(APIToken.self)
                    completion(.success(token))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
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

        apiProvider.request(.oneTimePassword(email: email)) { result in
            switch result {
            case .success(let response):
                do {
                    //  convert JSON response into our 'decodable' model object using Moya's own .map function.
                    //  let rawJSON = try response.mapJSON()
                    //  DDLogDebug("raw JSON: \(rawJSON)\n")
                    let message = try response.mapString()
                    completion(.success(message))
                } catch {
                    DDLogError("JSON MAPPING ERROR = \(error)")
                    completion(.failure(JSONError.failedToMapData.message))
                }
            case .failure(let error):
                completion(.failure(getAppErrorFromMoya(with: error)))
            }
        }
    }


}
