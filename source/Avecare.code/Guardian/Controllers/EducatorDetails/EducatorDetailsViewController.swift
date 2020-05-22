import UIKit



class EducatorDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var dataProvider: EducatorDetailsDataProvider = DefaultEducatorDetailsDataProvider()

    var selectedEducator: EducatorSummaryTableViewCellModel? = nil {
        didSet {
            if let selectedEducator = selectedEducator {
                dataProvider.addEducatorSummary(model: selectedEducator)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(nibModels: [
            EducatorSummaryTableViewCellModel.self,
            LogsNoteTableViewCellModel.self
        ])
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
