import Foundation



protocol ProfileDataProvider: class {
    var subjectsProvider: SubjectListDataProvider { get }
    var educatorsProvider: EducatorsDataProvider { get }
    var subjectSelection: SubjectSelectionProtocol? { get set }

    var unitIds: [String] { get set }
    var numberOfSections: Int { get }
    func numberOfRows(for section: Int) -> Int
    func model(for indexPath: IndexPath) -> AnyCellViewModel
    func details(at indexPath: IndexPath) -> ProfileDetails
}


class DefaultProfileDataProvider: ProfileDataProvider {

    private struct Section {
        let profileMenus: [ProfileMenuTableViewCellModel]
    }

    let subjectsProvider: SubjectListDataProvider = DefaultSubjectListDataProvider()
    let educatorsProvider: EducatorsDataProvider = DefaultEducatorsDataProvider()
    weak var subjectSelection: SubjectSelectionProtocol?

    var unitIds = [String]() {
        didSet {
            educatorsProvider.unitIds = unitIds
        }
    }

    private lazy var dataSource: [Section] = [
        Section(profileMenus: [
            ProfileMenuTableViewCellModel(menuImage: "utensils", menuTitle: "Menu")
//            ProfileMenuTableViewCellModel(menuImage: "calendar", menuTitle: "Activity")
        ]),
        Section(profileMenus: [
            ProfileMenuTableViewCellModel(menuImage: "", menuTitle: "About the Application")
        ]),
        Section(profileMenus: [
            ProfileMenuTableViewCellModel(menuImage: "", menuTitle: "Log Out", disclosable: false)
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
            return SupervisorFilterTableViewCellModel(dataProvider: educatorsProvider)
        default:
            return dataSource[indexPath.section - 2].profileMenus[indexPath.row]
        }
    }

    func details(at indexPath: IndexPath) -> ProfileDetails {
        return .mealPlan
    }

}
