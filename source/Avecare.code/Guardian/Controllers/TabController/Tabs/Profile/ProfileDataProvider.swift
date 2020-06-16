import Foundation



protocol ProfileDataProvider: class {
    var subjectsProvider: SubjectListDataProvider { get }
    var supervisorsProvider: SupervisorsDataProvider { get }
    var subjectSelection: SubjectSelectionProtocol? { get set }

    var unitIds: [String] { get set }
    var numberOfSections: Int { get }
    func numberOfRows(for section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel
    func details(at indexPath: IndexPath) -> ProfileDetails
}


enum ProfileSection: Int {
    case subjects = 0
    case supervisors = 1
    case details = 2
    case about = 3
    case logout = 4
}


class DefaultProfileDataProvider: ProfileDataProvider {

    private struct Section {
        let profileMenus: [ProfileMenuTableViewCellModel]
    }

    let subjectsProvider: SubjectListDataProvider = DefaultSubjectListDataProvider()
    let supervisorsProvider: SupervisorsDataProvider = DefaultSupervisorsDataProvider()
    weak var subjectSelection: SubjectSelectionProtocol?

    var unitIds = [String]() {
        didSet {
            supervisorsProvider.unitIds = unitIds
        }
    }

    private lazy var dataSource: [Section] = [
        Section(profileMenus: [
            ProfileMenuTableViewCellModel(menuImage: "utensils", menuTitle: NSLocalizedString("profile_menu_meal_plan", comment: ""))
//            ProfileMenuTableViewCellModel(menuImage: "calendar", menuTitle: NSLocalizedString("profile_menu_activity", comment: ""))
        ]),
        Section(profileMenus: [
            ProfileMenuTableViewCellModel(menuImage: "", menuTitle: NSLocalizedString("profile_menu_about_application", comment: ""))
        ]),
        Section(profileMenus: [
            ProfileMenuTableViewCellModel(menuImage: "", menuTitle: NSLocalizedString("profile_menu_logout", comment: ""), disclosable: false)
        ])
    ]

    var numberOfSections: Int {
        return dataSource.count + 2
    }

    func numberOfRows(for section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        default:
            return dataSource[section - 2].profileMenus.count
        }
    }

    func model(for indexPath: IndexPath) -> AnyCellViewModel {
        switch indexPath.section {
        case 0:
            return ProfileSubjectTableViewCellModel(dataProvider: subjectsProvider)
        case 1:
            return SupervisorFilterTableViewCellModel(dataProvider: supervisorsProvider)
        default:
            return dataSource[indexPath.section - 2].profileMenus[indexPath.row]
        }
    }

    func details(at indexPath: IndexPath) -> ProfileDetails {
        return .mealPlan
    }

}
