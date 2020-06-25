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
    case guardianDetails(id: String)
    case guardianFeed(id: String)
//    case guardianLogs(id: String)
    case guardianSubjects(id: String)
    // MARK: - INSTITUTIONS
    case institutionDetails(id: String)
//    case institutionUnits(id: String)
    // MARK: - MESSEAGES
    case message(id: String)
    // MARK: - ORGANIZATION
//    case organizationList
    case organizationDetails(id: String)
    case organizationDailyTemplates(id: String)
//    case organizationInstitutions(id: String)
    case organizationSubjectTypes(id: String)
    case organizationDailyTasks(id: String)
    case organizationActivities(id: String)
    case organizationInjuries(id: String)
    case organizationReminders(id: String)
    // MARK: - FEEDS
    case unitActivity(id: String)
    case subjectInjury(id: String)
    case subjectReminder(id: String)
    // MARK: - SUBJECTS
//    case subjectInjuries(id: String)
    case subjectPublishDailyLog(request: LogFormAPIModel)
    case subjectGetLogs(request: SubjectsAPIService.SubjectLogsRequest)
    // MARK: - SUPERVISORS
    case supervisorDetails(id: String)
    // MARK: - STORIES
    case unitStories(id: String)
    case storyDetails(id: String)
    // MARK: - NOTIFICATIONS
    case unitCreateActivity(id: String, request: RLMActivity)
    case unitCreateInjury(payLoad: [RLMInjury])
    case unitCreateReminder(payLoad: [RLMReminder])
    // MARK: - UNITS
    case unitDetails(id: String)
    case unitPublishDailyTaskForm(id: String, request: RLMDailyTaskForm)
    case unitSubjects(id: String)
    case unitSupervisors(id: String)
    case unitPublishStory(story: PublishStoryRequestModel)
//    case unitPublishedStories(unitId: String)
    case unitPublishedStories(request: PublishedStoriesRequestModel)

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
        case .guardianFeed(let id): return "/guardians/\(id)/feed/"
        case .guardianSubjects(let id): return "/guardians/\(id)/subjects"

        case .institutionDetails(let id): return "/institutions/\(id)"
//        case .institutionUnits(let id): return "/institutions/\(id)/units"

        case .message(let id): return "/messages/\(id)"

//        case .organizationList: return "/organizations"
        case .organizationDetails(let id): return "/organizations/\(id)"
        case .organizationDailyTemplates(let id): return "/organizations/\(id)/daily-subject-log-templates"
//        case .organizationInstitutions(let id): return "/organizations/\(id)/institutions"
        case .organizationSubjectTypes(let id): return "/organizations/\(id)/subject-types"     // might not be required
        case .organizationDailyTasks(let id): return "/organizations/\(id)/available-daily-tasks"
        case .organizationActivities(let id): return "/organizations/\(id)/available-activities"
        case .organizationInjuries(let id): return "/organizations/\(id)/available-injuries"
        case .organizationReminders(let id): return "/organizations/\(id)/available-reminders"

        case .subjectInjury(let id): return "/subject-injuries/\(id)/"
        case .subjectReminder(let id): return "/subject-reminders/\(id)/"
        case .unitActivity(let id): return "/unit-activities/\(id)"

        case .subjectPublishDailyLog(let request): return "/subjects/\(request.subjectId)/daily-logs/"
        case .subjectGetLogs(let request): return "/subjects/\(request.subjectId)/daily-logs/"

        case .supervisorDetails(let id): return "/supervisors/\(id)"

        case .unitStories(let id): return "/units/\(id)/stories"
        case .storyDetails(let id): return "/stories/\(id)"

        case .unitCreateActivity(let id, _): return "/units/\(id)/activities/"
        case .unitCreateInjury( _): return "/subject-injuries/"
        case .unitCreateReminder( _): return "/subject-reminders/"

        case .unitDetails(let id): return "/units/\(id)"
        case .unitPublishDailyTaskForm(let id, _): return "/units/\(id)/daily-tasks/"
        case .unitSubjects(let id): return "/units/\(id)/subjects"
        case .unitSupervisors(let id): return "/units/\(id)/supervisors"
        case .unitPublishStory(let story): return "/units/\(story.unitId)/stories/"
        case .unitPublishedStories(let request): return "/units/\(request.unitId)/stories"

        }
    }

    var method: Moya.Method {
        switch self {
        case .login,
             .oneTimePassword,
             .logout,
             .unitCreateActivity,
             .unitPublishDailyTaskForm,
             .unitCreateInjury,
             .unitCreateReminder,
             .subjectPublishDailyLog,
             .unitPublishStory:
            return .post
        default: return .get
        }
    }

    var task: Task {
        switch self {
        case .login(let credentials):
            return .requestJSONEncodable(credentials)

        case .oneTimePassword(let email):
            return .requestParameters(parameters: ["email": email], encoding: JSONEncoding.default)

        case .unitCreateActivity(_, let request as Encodable),
             .unitPublishDailyTaskForm(_, let request as Encodable),
             .unitCreateInjury(let request as Encodable),
             .unitCreateReminder(let request as Encodable):
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(Date.yearMonthDayFormatter)
            return .requestCustomJSONEncodable(request, encoder: encoder)

        case .subjectGetLogs(let request):
            DDLogDebug(".subjectGetLogs parameters: .serverLastUpdated = \(request.serverLastUpdated)")
            return .requestParameters(parameters: [
                "startDate": request.startDate,
                "endDate": request.endDate,
                "lastUpdatedAt": request.serverLastUpdated
            ], encoding: URLEncoding.default)

        case .unitPublishedStories(let request):
            DDLogDebug(".unitPublishedStories parameters: .serverLastUpdated = \(request.serverLastUpdated)")
            return .requestParameters(parameters: [
//                "limit": request.resultsLimit,
                "lastUpdatedAt": request.serverLastUpdated
            ], encoding: URLEncoding.default)

        case .subjectPublishDailyLog(let request as MultipartEncodable),
             .unitPublishStory(let request as MultipartEncodable):
            return .uploadMultipart(request.formData)

        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        switch self {
        case .login,
             .oneTimePassword:
            return ["Content-Type": "application/json"]

        default:
            return ["Authorization": "Token \(appSession.token.accessToken)"]
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
