import Foundation
import UIKit
//import Panels



protocol SubjectListViewControllerDelegate: class {
    func subjectList(_ controller: SubjectListViewController, didSelect item: SubjectListTableViewCellModel)
}

class SubjectListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: SubjectListViewControllerDelegate?
    var dataProvider: SubjectListDataProvider = DefaultSubjectListDataProvider()

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
}
