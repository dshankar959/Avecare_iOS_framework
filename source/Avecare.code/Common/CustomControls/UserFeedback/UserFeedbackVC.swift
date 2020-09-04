import UIKit
import CocoaLumberjack
import SnapKit



class UserFeedbackVC: UITableViewController, IndicatorProtocol {

    // MARK: - Properties
    var viewModel: UserFeedbackViewModel!     // Always valid through dependency injection.



    // MARK: - Initializers(...)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        DDLogInfo("")
    }


    init(withViewModel modelController: UserFeedbackViewModel) {
        super.init(nibName: nil, bundle: nil)
        DDLogInfo("")

        self.viewModel = modelController
    }


    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureNavigationBar()
    }


    private func configureTableView() {
        tableView.register(MultilineTextTableViewCell.self, forCellReuseIdentifier: MultilineTextTableViewCell.reuseIdentifier)
        tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.reuseIdentifier)
        tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.reuseIdentifier)

        // By adding an empty footer view the separator lines only appear for cells with content.
        tableView.tableFooterView = UIView()
    }


    private func configureNavigationBar() {
        self.navigationItem.title = "Feedback"
    }


    deinit {
        DDLogWarn("\(self)")
    }

}
