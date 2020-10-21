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
        case .institutionDetails:
            return "{\"id\":\"test_institution_id\",\"isActive\":true,\"name\":\"Test School\",\"mealPlan\":\"https://sample.mealplan.link\",\"organizationId\":\"test_organization_id\"}".utf8Encoded
        case .unitDetails:
            return "{\"id\":\"test_unit_id\",\"institutionId\":\"test_institution_id\",\"name\":\"Test Class\"}".utf8Encoded
        case .unitSubjects:
            return "{\"count\":2,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"first_subject_id\",\"firstName\":\"First\",\"middleName\":\"Sample\",\"lastName\":\"Subject\",\"birthday\":\"2011-09-17\",\"profilePhoto\":\"https://sample.profilePhoto.link\",\"subjectTypeId\":\"first_subject_type_id\",\"unitIds\":[\"sample_unit_id\"],\"photoConsent\":true},{\"id\":\"second_subject_id\",\"firstName\":\"Second\",\"middleName\":\"Sample\",\"lastName\":\"Subject\",\"birthday\":\"2015-06-22\",\"profilePhoto\":\"https://sample.profilePhoto.link\",\"subjectTypeId\":\"second_subject_type_id\",\"unitIds\":[\"sample_unit_id\"],\"photoConsent\":true}]}".utf8Encoded
        case .unitSupervisors:
            return "{\"count\":2,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"first_supervisor_id\",\"title\":\"Ms\",\"firstName\":\"First\",\"middleName\":\"Supervisor\",\"lastName\":\"Name\",\"isUnitType\":false,\"primaryUnitId\":\"sample_unit_id\",\"showInUnitList\":true},{\"id\":\"second_supervisor_id\",\"title\":\"Mr\",\"firstName\":\"Second\",\"middleName\":\"Supervisor\",\"lastName\":\"Name\",\"isUnitType\":true,\"primaryUnitId\":\"sample_unit_id\",\"showInUnitList\":true}]}".utf8Encoded
        case .unitPublishStory:
            return "{\"id\":\"sample_story_id\",\"createdAt\":\"2020-10-21T18:32:33.539114Z\",\"updatedAt\":\"2020-10-21T18:32:33.539114Z\",\"unitId\":\"test_unit_id\",\"storyFile\":\"https://sample.storyFile.link\",\"title\":\"Test Story\"}".utf8Encoded
        case .unitPublishedStories:
            return "{\"count\":2,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"first_story_id\",\"createdAt\":\"2020-08-19T13:18:54.752220Z\",\"updatedAt\":\"2020-08-19T13:18:54.752220Z\",\"unitId\":\"test_unit_id\",\"storyFile\":\"https://first.storyFile.link\",\"title\":\"First Story\"},{\"id\":\"second_story_id\",\"createdAt\":\"2020-10-21T18:32:33.539114Z\",\"updatedAt\":\"2020-10-21T18:32:33.539114Z\",\"unitId\":\"test_unit_id\",\"storyFile\":\"https://second.storyFile.link\",\"title\":\"Second Story\"}]}".utf8Encoded
        case .unitPublishedDailyTaskForms:
            return "{\"count\":1,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"sample_daily_task_form_id\",\"date\":\"2020-10-21\",\"tasks\":[{\"id\":\"first_daily_task_id\",\"completed\":true},{\"id\":\"second_daily_task_id\",\"completed\":false}]}]}".utf8Encoded
        case .subjectPublishDailyLog:
            return "{\"id\":\"sample_log_form_id\",\"createdAt\":\"2020-10-21T17:18:15.841582-04:00\",\"updatedAt\":\"2020-10-21T17:18:16.530155-04:00\",\"subjectId\":\"sample_subject_id\",\"date\":\"2020-10-21\",\"log\":{\"rows\":[{\"rowType\":2,\"properties\":{\"startTime\":\"12:00PM\",\"title\":\"Rest\",\"iconName\":\"cloud-icon\",\"endTime\":\"1:00PM\",\"iconColor\":\"FBD476\"}},{\"rowType\":4,\"properties\":{\"value\":\"Test note\",\"title\":\"Educator\'s Note\",\"iconName\":\"pencil-icon\",\"iconColor\":\"00B0CA\"}},{\"rowType\":3,\"properties\":{\"selectedValue\":2,\"subtitle\":\"Number of servings eaten:\",\"endTime\":\"1:00PM\",\"iconName\":\"spoon-icon\",\"title\":\"Lunch\",\"startTime\":\"12:00PM\",\"options\":[{\"value\":1,\"text\":\"1-2\"},{\"value\":2,\"text\":\"3-4\"},{\"value\":3,\"text\":\"5-6\"}],\"iconColor\":\"FBD476\"}}]},\"files\":[{\"id\":\"sample_file_id\",\"fileName\":\"sample_file_name.jpg\",\"fileUrl\":\"https://sample.file.link\"}]}".utf8Encoded
        case .subjectGetLogs:
            return "{\"count\":1,\"next\":null,\"previous\":null,\"results\":[{\"id\":\"sample_log_form_id\",\"createdAt\":\"2020-10-21T17:18:15.841582-04:00\",\"updatedAt\":\"2020-10-21T17:18:16.530155-04:00\",\"subjectId\":\"sample_subject_id\",\"date\":\"2020-10-21\",\"log\":{\"rows\":[{\"rowType\":2,\"properties\":{\"startTime\":\"12:00PM\",\"title\":\"Rest\",\"iconName\":\"cloud-icon\",\"endTime\":\"1:00PM\",\"iconColor\":\"FBD476\"}},{\"rowType\":4,\"properties\":{\"value\":\"Test note\",\"title\":\"Educator\'s Note\",\"iconName\":\"pencil-icon\",\"iconColor\":\"00B0CA\"}},{\"rowType\":3,\"properties\":{\"selectedValue\":2,\"subtitle\":\"Number of servings eaten:\",\"endTime\":\"1:00PM\",\"iconName\":\"spoon-icon\",\"title\":\"Lunch\",\"startTime\":\"12:00PM\",\"options\":[{\"value\":1,\"text\":\"1-2\"},{\"value\":2,\"text\":\"3-4\"},{\"value\":3,\"text\":\"5-6\"}],\"iconColor\":\"FBD476\"}}]},\"files\":[{\"id\":\"sample_file_id\",\"fileName\":\"sample_file_name.jpg\",\"fileUrl\":\"https://sample.file.link\"}]}]}".utf8Encoded
        default:
            return "default data".utf8Encoded
        }
    }
    // swiftlint: enable line_length
}
