import UIKit



class EducatorDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var drawerView: UIView!

    private var dataProvider: EducatorDetailsDataProvider = DefaultEducatorDetailsDataProvider()

    var selectedEducatorId: String = "" {
        didSet {
            dataProvider.createDataProvider(with: selectedEducatorId)
        }
    }

    var panningInterationController: PanningInteractionController?
    var direction: PresentationDirection = .bottom

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(nibModels: [
            EducatorBioTableViewCellModel.self,
            LogsNoteTableViewCellModel.self
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

extension EducatorDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataProvider.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataProvider.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataProvider.model(for: indexPath)
        return tableView.dequeueReusableCell(withAnyModel: model, for: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableView.automaticDimension
        } else {
            return 80
        }
    }
}
