import UIKit


protocol SubjectListDataProvider: class {
    var numberOfRows: Int { get }

    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel
}


class DefaultSubjectListDataProvider: SubjectListDataProvider {

    private let listIncludesAllSelection: Bool
    let storage = ImageStorageService()

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

    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel {
        return SubjectListTableViewCellModel(with: dataSource[indexPath.row], storage: storage)
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
