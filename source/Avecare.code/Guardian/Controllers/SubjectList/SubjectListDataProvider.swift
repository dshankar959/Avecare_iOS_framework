import UIKit



protocol SubjectListDataProvider: class {
    var numberOfRows: Int { get }

    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel
}


class DefaultSubjectListDataProvider: SubjectListDataProvider {

    private let allSubjectsIncluded: Bool
    let storage = ImageStorageService()

    init(allSubjectsIncluded: Bool? = nil) {
        self.allSubjectsIncluded = allSubjectsIncluded ?? false
    }

    private lazy var dataSource = RLMSubject.findAll(sortedBy: "firstName")

    var numberOfRows: Int {
        if allSubjectsIncluded {
            return dataSource.count
        } else {
            return dataSource.count - 1
        }
    }

    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel {
        if allSubjectsIncluded {
            return SubjectListTableViewCellModel(with: dataSource[indexPath.row], storage: storage)
        } else {
            return SubjectListTableViewCellModel(with: dataSource[indexPath.row + 1], storage: storage)
        }
    }
}


extension SubjectListTableViewCellModel {
    init(with subject: RLMSubject, storage: ImageStorageService) {
        title = "\(subject.firstName) \(subject.lastName)"
        photo = subject.photoURL(using: storage)
    }
}
