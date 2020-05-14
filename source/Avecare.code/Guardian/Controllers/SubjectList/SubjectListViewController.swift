import Foundation
import UIKit
//import Panels



protocol SubjectListViewControllerDelegate: class {
    func subjectList(_ controller: SubjectListViewController, didSelect item: SubjectListTableViewCellModel)
}

class SubjectListViewController: UIViewController {
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: SubjectListViewControllerDelegate?
    var allSubjectsIncluded = false
    var dataProvider: SubjectListDataProvider {
        if allSubjectsIncluded {
            return DefaultSubjectListDataProvider(allSubjectsIncluded: true)
        } else {
            return DefaultSubjectListDataProvider()
        }
    }

    private let cellHeight = CGFloat(57)
    var contentHeight: CGFloat {
        return CGFloat(dataProvider.numberOfRows) * cellHeight + 24
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        drawerView.layer.cornerRadius = drawerView.frame.height / 2
        drawerView.clipsToBounds = true
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
