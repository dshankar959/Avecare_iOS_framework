import Foundation
import UIKit



protocol SubjectListViewControllerDelegate: class {
    func subjectList(_ controller: SubjectListViewController, didSelect item: SubjectListTableViewCellModel)
}


class SubjectListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: SubjectListViewControllerDelegate?

    var allSubjectsIncluded = true

    var dataProvider: SubjectListDataProvider {
        if allSubjectsIncluded {
            return DefaultSubjectListDataProvider(allSubjectsIncluded: true)
        } else {
            return DefaultSubjectListDataProvider()
        }
    }

    private let cellHeight = CGFloat(57)
    var contentHeight: CGFloat {
        return CGFloat(dataProvider.numberOfRows) * cellHeight
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}


extension SubjectListViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        return tableView.dequeueReusableCell(withModel: model, for: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.subjectList(self, didSelect: dataProvider.model(for: indexPath))
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}
