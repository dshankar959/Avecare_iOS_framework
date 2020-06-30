import Foundation
import UIKit



protocol SubjectListViewControllerDelegate: class {
    func subjectListDidSelectAll(_ controller: SubjectListViewController)
    func subjectList(_ controller: SubjectListViewController, didSelect subject: RLMSubject)
}


class SubjectListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var drawerView: UIView!

    weak var delegate: SubjectListViewControllerDelegate?
    lazy var dataProvider: SubjectListDataProvider = DefaultSubjectListDataProvider()

    private let cellHeight = CGFloat(57)
    private let drawerHeight = CGFloat(22)
    var contentHeight: CGFloat {
        // should not be greater then screen size -> This is done by SlideInPresentationController
        return CGFloat(dataProvider.numberOfRows) * cellHeight + drawerHeight
    }

    var panningInterationController: PanningInteractionController?
    var direction: PresentationDirection = .bottom

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(viewModels: [
            SubjectListAllTableViewCell.self
        ])

        // Make drawer view
        drawerView.layer.cornerRadius = drawerView.frame.height / 2
        drawerView.clipsToBounds = true
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        panningInterationController = PanningInteractionController(viewController: self, direction: direction)
    }
}


extension SubjectListViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.listCellViewModel(for: indexPath)
        return tableView.dequeueReusableCell(withAnyModel: model, for: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataProvider.allSubjectsIncluded, indexPath.row == 0 {
            delegate?.subjectListDidSelectAll(self)
        } else {
            delegate?.subjectList(self, didSelect: dataProvider.model(at: indexPath))
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}
