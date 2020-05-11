import Foundation
import CocoaLumberjack
import Moya
import Alamofire


/*
Terms           Daycare Term
----------------------------
Organization    School Board
Institution     School
Unit            Room
Subject         Student/Child
Supervisor      Teacher/Educator
Guardian        Parent of the child
*/


var apiProvider: MoyaProvider<AvecareAPI> {
    #if APPSTORE
    return MoyaProvider<AvecareAPI>(session: DefaultAlamofireManager.sharedManager)
    #else
    if !appSettings.isTesting {
        if appSettings.isHTTPlogging == true {
            return MoyaProvider<AvecareAPI>(session: DefaultAlamofireManager.sharedManager,
                    plugins: [DDLogNetworkPlugin(verbose: true)])     // extra network logging
        } else {
            return MoyaProvider<AvecareAPI>(session: DefaultAlamofireManager.sharedManager)   // no network logging  (less noisy)
        }
    } else { // unit testing
        return MoyaProvider<AvecareAPI>(stubClosure: MoyaProvider.immediatelyStub, // mock data
                session: DefaultAlamofireManager.sharedManager,
                plugins: [DDLogNetworkPlugin(verbose: true)])         // extra network logging
    }
    #endif
}


private struct APIConfig {
    static let timeoutInterval: TimeInterval = 60 * 5 // seconds * minutes
    static let apiVersion = "v1"
}


enum AvecareAPI { // API Services
    // MARK: - USER
    case login(creds: UserCredentials)
    case logout
    case oneTimePassword(email: String)
    // MARK: - ACCOUNTS
    case accountInfo
    // MARK: - GUARDIANS
    case guardianDetails(id: Int)
//    case guardianFeed(id: Int)
//    case guardianLogs(id: Int)
    case guardianSubjects(id: Int)
    // MARK: - INSTITUTIONS
    case institutionDetails(id: Int)
//    case institutionUnits(id: Int)
    // MARK: - ORGANIZATION
//    case organizationList
    case organizationDetails(id: Int)
    case organizationDailyTemplates(id: Int)
//    case organizationInstitutions(id: Int)
    case organizationSubjectTypes(id: Int)
    // MARK: - SUBJECTS
//    case subjectInjuries(id: Int)
//    case subjectCreateLogs(id: Int)
    // MARK: - SUPERVISORS
    case supervisorDetails(id: Int)
    // MARK: - STORIES
    case unitStories(id: Int)
    case storyDetails(id: Int)
    // MARK: - UNITS
    case unitDetails(id: Int)
    case unitActivities(id: Int)
    case unitCreateActivity(id: Int, request: CreateUnitActivityRequest)
    case unitDailyTasks(id: Int)
    case unitPublishDailyTasks(id: Int, request: DailyTaskRequest)
    case unitInjuries(id: Int)
    case unitCreateInjury(id: Int)
    case unitReminders(id: Int)
    case unitCreateReminder(id: Int)
    case unitSubjects(id: Int)
    case unitSupervisors(id: Int)

}


extension AvecareAPI: TargetType {
    var baseURL: URL {
        return URL(string: appSettings.serverURLstring + "/api/\(APIConfig.apiVersion)")!
    }

    var path: String {
//        DDLogDebug("path")
        switch self {
        case .login: return "/users/login"
        case .logout: return "/users/logout"
        case .oneTimePassword: return "/users/otp"

        case .accountInfo: return "/accounts"

        case .guardianDetails(let id): return "/guardians/\(id)"
        case .guardianSubjects(let id): return "/guardians/\(id)/subjects"

        case .institutionDetails(let id): return "/institutions/\(id)"
//        case .institutionUnits(let id): return "/institutions/\(id)/units"

//        case .organizationList: return "/organizations"
        case .organizationDetails(let id): return "/organizations/\(id)"
        case .organizationDailyTemplates(let id): return "/organizations/\(id)/daily-subject-log-templates"
//        case .organizationInstitutions(let id): return "/organizations/\(id)/institutions"
        case .organizationSubjectTypes(let id): return "/organizations/\(id)/subject-types"     // might not be required

        case .unitDetails(let id): return "/units/\(id)"
        case .unitActivities(let id): return "/units/\(id)/available-activities"
        case .unitCreateActivity(let id, _): return "/units/\(id)/activities"
        case .unitDailyTasks(let id): return "/units/\(id)/available-daily-tasks"
        case .unitPublishDailyTasks(let id, _): return "/units/\(id)/daily-tasks"
        case .unitInjuries(let id): return "/units/\(id)/available-injuries"
        case .unitCreateInjury(let id): return "/units/\(id)/injuries"
        case .unitReminders(let id): return "/units/\(id)/available-reminders"
        case .unitCreateReminder(let id): return "/units/\(id)/reminders"
        case .unitSubjects(let id): return "/units/\(id)/subjects"
        case .unitSupervisors(let id): return "/units/\(id)/supervisors"

        case .unitStories(let id): return "/units/\(id)/stories"
        case .storyDetails(let id): return "/stories/\(id)"

        case .supervisorDetails(let id): return "/supervisors/\(id)"
        }
    }

    var method: Moya.Method {
//        DDLogDebug("method")
        switch self {
        case .login,
             .oneTimePassword,
             .logout,
             .unitCreateActivity,
             .unitPublishDailyTasks,
             .unitCreateInjury,
             .unitCreateReminder:
            return .post
        default:
            return .get
        }
    }

    var task: Task {
//        DDLogDebug("task")
        switch self {
        case .login(let credentials):
            return .requestJSONEncodable(credentials)
        case .oneTimePassword(let email):
            return .requestParameters(parameters: ["email": email], encoding: JSONEncoding.default)
        case .unitCreateActivity(_, let request as Encodable),
             .unitPublishDailyTasks(_, let request as Encodable):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(Date.ymdFormatter)
            return .requestCustomJSONEncodable(request, encoder: encoder)
        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
//        DDLogDebug("headers")
        switch self {
        case .login,
             .oneTimePassword:
            return ["Content-Type": "application/json"]

        default:
            return ["Authorization": "Token \(appSession.token.accessToken)"]
        }
    }

    // MARK: - MultipartData -
    // ref: https://stackoverflow.com/questions/49568660/how-to-upload-image-using-multipart-request-with-moya-swift
    var multipartBody: [Moya.MultipartFormData]? {

        switch self {
/*
        case .uploadFile(let ofType, _, let filePathURL, let withJSONparameters):
            var formData: [Moya.MultipartFormData] = []

            if let filePath = filePathURL {
                if ofType is RLMFeedback.Type {
                    DDLogDebug(".uploadFile(feedback):")
                    if let fileData = try? Data(contentsOf: filePath) {
                        let filenameWithExtension = filePath.lastPathComponent
                        formData.append(Moya.MultipartFormData(provider: .data(fileData),
                                                               name: "attachment",
                                                               fileName: filenameWithExtension,
                                                               mimeType: "application/octet-stream"))
                    }
                } else {  // image
                    DDLogDebug(".uploadFile(image):")
                    if let image = UIImage(contentsOfFile: filePath.path) {
                        if let imageData = image.jpegData(compressionQuality: 1.0) {
                            let filenameWithExtension = filePath.lastPathComponent
                            formData.append(Moya.MultipartFormData(provider: .data(imageData),
                                                                   name: "attachment_upload",
                                                                   fileName: filenameWithExtension,
                                                                   mimeType: "image/jpg"))
                        }
                    }
                }
            }

            if let parameters = withJSONparameters {
                for (key, value) in parameters {
                    let valueString = "\(value)"
                    let valueData = valueString.data(using: String.Encoding.utf8) ?? Data()
                    formData.append(Moya.MultipartFormData(provider: .data(valueData), name: key))
                }
            }

            return formData
*/
        default:
            return []
        }

    }

    // Filter HTTP status codes from 200-399
    var validationType: ValidationType {
        return .successCodes
    }

}


// Set timeout for requests using Moya.  (https://stackoverflow.com/a/41428250/7599)
class DefaultAlamofireManager: Alamofire.Session {
    static let sharedManager: DefaultAlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = HTTPHeaders.default.dictionary
        configuration.timeoutIntervalForRequest = APIConfig.timeoutInterval   // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = APIConfig.timeoutInterval  // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        let manager = DefaultAlamofireManager(configuration: configuration,
                redirectHandler: Redirector(behavior: .modify { task, request, _ in
                    // handle redirects
                    if let originalRequest = task.originalRequest,
                       let headers = originalRequest.allHTTPHeaderFields,
                       let authorizationHeaderValue = headers["Authorization"] {
                        var request = request
                        request.setValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
                        return request
                    }
                    return request
                }))
        return manager
    }()
}
