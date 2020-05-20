import UIKit


protocol SubjectListDataProvider: class {
    var numberOfRows: Int { get }

    func listTableViewmodel(for indexPath: IndexPath) -> SubjectListTableViewCellModel
    func imageCollectionViewmodel(for indexPath: IndexPath) -> ProfileSubjectImageCollectionViewCellModel
}


class DefaultSubjectListDataProvider: SubjectListDataProvider {

    private let listIncludesAllSelection: Bool
    private let storage = ImageStorageService()

    init(listIncludesAllSelection: Bool? = nil) {
        self.listIncludesAllSelection = listIncludesAllSelection ?? false
    }

    private var dataSource: [RLMSubject] {
        var subjects = RLMSubject.findAll(sortedBy: "firstName")
        if listIncludesAllSelection {
            let allSelection = RLMSubject()
            allSelection.firstName = "All"
            subjects.insert(allSelection, at: 0)
        }
        return subjects
    }

    var numberOfRows: Int {
        if listIncludesAllSelection {
            return dataSource.count
        } else {
            return dataSource.count
        }
    }

    func listTableViewmodel(for indexPath: IndexPath) -> SubjectListTableViewCellModel {
        return SubjectListTableViewCellModel(with: dataSource[indexPath.row], storage: storage)
    }

    func imageCollectionViewmodel(for indexPath: IndexPath) -> ProfileSubjectImageCollectionViewCellModel {
        return ProfileSubjectImageCollectionViewCellModel(with: dataSource[indexPath.row], storage: storage)
    }
}


extension SubjectListTableViewCellModel {
    init(with subject: RLMSubject, storage: ImageStorageService) {
        if subject.id.count > 0 {
            id = subject.id
        } else {
            id = nil
        }

        title = "\(subject.firstName) \(subject.lastName)"
        photo = subject.photoURL(using: storage)
    }
}

extension ProfileSubjectImageCollectionViewCellModel {
    init(with subject: RLMSubject, storage: ImageStorageService) {
        id = subject.id
        fullName = "\(subject.firstName) \(subject.lastName)"
        photo = subject.photoURL(using: storage)
        birthDay = subject.birthday
    }
}
