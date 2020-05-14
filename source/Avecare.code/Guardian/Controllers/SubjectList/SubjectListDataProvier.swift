import Foundation
import UIKit

protocol SubjectListDataProvider: class {
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel
}

class DefaultSubjectListDataProvider: SubjectListDataProvider {

    private let allSubjectsIncluded: Bool

    init(allSubjectsIncluded: Bool? = nil) {
        self.allSubjectsIncluded = allSubjectsIncluded ?? false
    }

    private let dataSource = [
        SubjectListTableViewCellModel(title: "All", photo: nil),
        SubjectListTableViewCellModel(title: "Subject 1", photo: R.image.subject1()),
        SubjectListTableViewCellModel(title: "Subject 2", photo: R.image.subject2()),
        SubjectListTableViewCellModel(title: "Subject 3", photo: R.image.subject3()),
        SubjectListTableViewCellModel(title: "Subject 4", photo: R.image.subject4()),
        SubjectListTableViewCellModel(title: "Subject 5", photo: R.image.subject5())
    ]

    var numberOfRows: Int {
        if allSubjectsIncluded {
            return dataSource.count
        } else {
            return dataSource.count - 1
        }
    }

    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel {
        if allSubjectsIncluded {
            return dataSource[indexPath.row]
        } else {
            return dataSource[indexPath.row + 1]
        }
    }
}
