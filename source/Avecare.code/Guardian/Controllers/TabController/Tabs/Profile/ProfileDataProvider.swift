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


enum ProfileSection: Int, CaseIterable {
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
        ]),
        Section(profileMenus: [
            ProfileMenuTableViewCellModel(menuImage: "", menuTitle: NSLocalizedString("profile_menu_about_application", comment: ""))
        ]),
        Section(profileMenus: [
            ProfileMenuTableViewCellModel(menuImage: "", menuTitle: NSLocalizedString("profile_menu_logout", comment: ""), disclosable: false)
        ])
    ]

    var numberOfSections: Int {
        return ProfileSection.allCases.count
    }

    func numberOfRows(for section: Int) -> Int {
        switch section {
        case ProfileSection.subjects.rawValue,
             ProfileSection.supervisors.rawValue:
            return 1
        default:
            return dataSource[section - 2].profileMenus.count
        }
    }

    func model(for indexPath: IndexPath) -> AnyCellViewModel {
        switch indexPath.section {
        case ProfileSection.subjects.rawValue:
            return ProfileSubjectTableViewCellModel(dataProvider: subjectsProvider)
        case ProfileSection.supervisors.rawValue:
            return SupervisorFilterTableViewCellModel(dataProvider: supervisorsProvider)
        default:
            return dataSource[indexPath.section - 2].profileMenus[indexPath.row]
        }
    }

    func details(at indexPath: IndexPath) -> ProfileDetails {
        return .mealPlan
    }

}
