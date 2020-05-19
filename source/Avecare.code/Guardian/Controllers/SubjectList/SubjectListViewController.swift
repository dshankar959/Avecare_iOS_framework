import Foundation
import UIKit



protocol SubjectListViewControllerDelegate: class {
    func subjectList(_ controller: SubjectListViewController, didSelect item: SubjectListTableViewCellModel)
}


class SubjectListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: SubjectListViewControllerDelegate?

    var listIncludesAllSelection = false

    var dataProvider: SubjectListDataProvider {
        if listIncludesAllSelection {
            return DefaultSubjectListDataProvider(listIncludesAllSelection: true)
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
        let selectedSubject = dataProvider.model(for: indexPath)
        selectedSubjectId = selectedSubject.id
        delegate?.subjectList(self, didSelect: selectedSubject)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}
