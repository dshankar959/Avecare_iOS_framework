import UIKit



protocol SubjectListDataProvider: class {
    var allSubjectsIncluded: Bool { get set }

    var numberOfRows: Int { get }

    func model(at indexPath: IndexPath) -> RLMSubject
    func cellViewModel(for indexPath: IndexPath) -> AnyCellViewModel
    func title(for indexPath: IndexPath) -> String
}


class DefaultSubjectListDataProvider: SubjectListDataProvider {

    var allSubjectsIncluded: Bool = false
    let storage = ImageStorageService()

    init(allSubjectsIncluded: Bool = false) {
        self.allSubjectsIncluded = allSubjectsIncluded
    }

    private lazy var dataSource = RLMSubject.findAll(sortedBy: "firstName")

    var numberOfRows: Int {
        if allSubjectsIncluded {
            return dataSource.count
        } else {
            return dataSource.count - 1
        }
    }

    func model(at indexPath: IndexPath) -> RLMSubject {
        if allSubjectsIncluded {
            return dataSource[indexPath.row - 1]
        } else {
            return dataSource[indexPath.row]
        }
    }

    func cellViewModel(for indexPath: IndexPath) -> AnyCellViewModel {
        if allSubjectsIncluded, indexPath.row == 0 {
            return SubjectListAllTableViewCell()
        }
        return SubjectListTableViewCellModel(with: model(at: indexPath), storage: storage)
    }

    func title(for indexPath: IndexPath) -> String {
        if allSubjectsIncluded, indexPath.row == 0 {
            return "All"
        }
        return model(at: indexPath).firstName
    }
}


extension SubjectListTableViewCellModel {
    init(with subject: RLMSubject, storage: ImageStorageService) {
        title = "\(subject.firstName) \(subject.lastName)"
        photo = subject.photoURL(using: storage)
    }
}
