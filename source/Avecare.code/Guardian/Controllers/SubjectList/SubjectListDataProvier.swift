import Foundation
import UIKit

protocol SubjectListDataProvider: class {
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel
}

class DefaultSubjectListDataProvider: SubjectListDataProvider {

    private let dataSource = [
        SubjectListTableViewCellModel(title: "Subject 1", photo: R.image.subject1()),
        SubjectListTableViewCellModel(title: "Subject 2", photo: R.image.subject2()),
        SubjectListTableViewCellModel(title: "Subject 3", photo: R.image.subject3()),
        SubjectListTableViewCellModel(title: "Subject 4", photo: R.image.subject4()),
        SubjectListTableViewCellModel(title: "Subject 5", photo: R.image.subject5())
    ]

    var numberOfRows: Int {
        return dataSource.count
    }

    func model(for indexPath: IndexPath) -> SubjectListTableViewCellModel {
        return dataSource[indexPath.row]
    }
}
