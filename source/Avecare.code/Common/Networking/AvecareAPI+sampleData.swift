import Foundation
import CocoaLumberjack
import Moya



extension AvecareAPI {

    // MARK: - JSON stubbed responses  (Javascript escaped)
    // https://www.freeformatter.com/json-formatter.html#ad-output

    // swiftlint:disable line_length
    var sampleData: Data {
        DDLogDebug("sampleData...  { Stubbed response }")
        switch self {
        case .login:
            return "{\"accountType\":\"guardian\",\"accountTypeId\":\"sample_id\",\"token\":\"sample_token\"}".utf8Encoded
        case .supervisorDetails:
            return "{\"id\":\"test_supervisor_id\",\"title\":\"\",\"firstName\":\"Test\",\"middleName\":\"\",\"lastName\":\"Supervisor\",\"bio\":\"\",\"educationalBackground\":[],\"primaryUnitId\":\"sample_unit_id\",\"profilePhoto\":null,\"employmentStatus\":\"full-time\",\"unitIds\":[\"sample_unit_id\"]}".utf8Encoded
        case .guardianDetails:
            return "{\"id\":\"test_guardian_id\",\"isActive\":true,\"homePhoneNumber\":\"+12345678901\",\"workPhoneNumber\":\"+12345678902\",\"mobilePhoneNumber\":\"+12345678903\"}".utf8Encoded
        case .guardianFeed:
            return "{\"count\":3,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"first_feed_id\",\"body\":\"Log is ready\",\"date\":\"2020-09-30T12:00:00.000000Z\",\"header\":\"Your Child\'s Daily Log\",\"important\":false,\"importantExpiry\":null,\"subjectIds\":[\"sample_subject_id\"],\"feedItemId\":\"b18e7663-6d3f-4917-bf3f-ef1d8656ee82\",\"feedItemType\":\"subjectdailylog\"},{\"id\":\"second_feed_id\",\"body\":\"Me\",\"date\":\"2020-09-22T13:51:33.099958Z\",\"header\":\"Documentation\",\"important\":false,\"importantExpiry\":null,\"subjectIds\":[\"sample_subject_id\"],\"feedItemId\":\"sample_feed_item_id\",\"feedItemType\":\"unitstory\"},{\"id\":\"third_feed_id\",\"body\":\"Log is ready\",\"date\":\"2020-09-02T12:00:00.000000Z\",\"header\":\"Your Child\'s Daily Log\",\"important\":false,\"importantExpiry\":null,\"subjectIds\":[\"sample_subject_id\"],\"feedItemId\":\"073e079d-23b9-4065-8e83-fdadf46b040e\",\"feedItemType\":\"subjectdailylog\"}]}".utf8Encoded
        case .guardianSubjects:
            return "{\"count\":2,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"first_subject_id\",\"firstName\":\"First\",\"middleName\":\"Sample\",\"lastName\":\"Subejct\",\"birthday\":\"2015-03-21\",\"profilePhoto\":\"https://link.photo/first_subject\",\"subjectTypeId\":\"first_subject_type_id\",\"unitIds\":[\"sample_unit_id\"],\"photoConsent\":true},{\"id\":\"second_subject_id\",\"firstName\":\"Second\",\"middleName\":\"Sample\",\"lastName\":\"Subject\",\"birthday\":\"2020-01-01\",\"profilePhoto\":\"https://link.photo/second_subject\",\"subjectTypeId\":\"second_subject_type_id\",\"unitIds\":[\"sample_unit_id\"],\"photoConsent\":true}]}".utf8Encoded
        case .organizationDetails:
            return "{\"id\":\"test_organization_id\",\"name\":\"Sample Organization\"}".utf8Encoded
        case .organizationDailyTemplates:
            return "{\"count\":1,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"sample_template_id\",\"version\":2,\"template\":[{\"name\":\"Rest\",\"rowType\":2,\"properties\":{\"title\":\"Rest\",\"endTime\":\"1:00pm\",\"iconName\":\"cloud-icon\",\"subtitle\":\"Select amount of sleep:\",\"iconColor\":\"FBD476\",\"startTime\":\"12:00pm\"}},{\"rowType\":7,\"properties\":{\"title\":\"Child\'s Emotions\",\"options\":[{\"text\":\"Happy\",\"value\":1},{\"text\":\"Sad\",\"value\":2},{\"text\":\"Excited\",\"value\":3},{\"text\":\"Anxious\",\"value\":4},{\"text\":\"Frustrated\",\"value\":5},{\"text\":\"Shy\",\"value\":6}],\"iconName\":\"heart-icon\",\"iconColor\":\"00B0CA\",\"placeholder\":\"Select Emotion\"}},{\"name\":\"Note\",\"rowType\":4,\"properties\":{\"title\":\"Educator\'s Note\",\"iconName\":\"pencil-icon\",\"iconColor\":\"00B0CA\"}},{\"name\":\"Photo\",\"rowType\":5,\"properties\":{\"title\":\"Caption\"}}],\"isActive\":true,\"organization\":\"test_organization_id\",\"subjectType\":\"sample_subejct_type_id\"}]}".utf8Encoded
        case .organizationDailyTasks:
            return "{\"count\":1,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"sample_task_id\",\"name\":\"sample_task_name\",\"description\":\"sample_task_description\",\"isActive\":true,\"order\":1}]}".utf8Encoded
        case .organizationActivities:
            return  "{\"count\":1,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"sample_activity_id\",\"name\":\"sample_activity_name\",\"description\":\"sample_activity_description\",\"isActive\":true}]}".utf8Encoded
        case .organizationInjuries:
            return "{\"count\":1,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"sample_injury_id\",\"name\":\"sample_injury_name\",\"description\":\"sample_injury_description\",\"isActive\":true}]}".utf8Encoded
        case .organizationReminders:
            return "{\"count\":1,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"sample_reminder_id\",\"name\":\"sample_reminder_name\",\"description\":\"sample_reminder_description\",\"isActive\":true,\"order\":1}]}".utf8Encoded
        default:
            return "default data".utf8Encoded
        }
    }
    // swiftlint: enable line_length
}
