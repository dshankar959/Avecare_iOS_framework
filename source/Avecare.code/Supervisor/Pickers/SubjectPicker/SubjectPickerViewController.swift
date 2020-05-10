import Foundation
import UIKit


extension SubjectPickerTableViewCellModel {
    init(details: RLMSubject, isSelected: Bool) {
        self.photo = UIImage.randomSubjectPhoto
        self.isSelected = isSelected
        self.subjectName = "\(details.firstName), \(details.lastName)"
    }
}

class SubjectPickerViewController: UIViewController {
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

//    var onDone: ((Results<RLMSubject>) -> Void)?
    var onDone: (([RLMSubject]) -> Void)?

//    lazy var dataSource: Results<RLMSubject> = {
    lazy var dataSource: [RLMSubject] = {
        return RLMSubject().findAll(sortedBy: "firstName")
    }()

    var selectedIds = Set<Int>()

    var isSelectedAll: Bool {
        return dataSource.count == selectedIds.count
    }

    func removeMissingIds() {
        selectedIds = selectedIds.filter { id in
            return dataSource.contains(where: {$0.id == id})
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didClickDoneButton(_ sender: UIButton) {
        dismiss(animated: true)
//        onDone?(dataSource.filter("id IN %@", selectedIds))

        let subjects = RLMSubject().findAllWith(Array(selectedIds))
        onDone?(subjects)
    }

    @IBAction func didClickSelectAllButton(_ sender: UIButton) {
        if isSelectedAll {
            selectedIds.removeAll()
        } else {
            selectedIds = Set(dataSource.map({ $0.id }))
        }
        tableView.reloadData()
        updateSelectAllButton()
    }

    private func updateSelectAllButton() {
        if isSelectedAll {
            selectAllButton.setImage(R.image.checkmark_on(), for: .normal)
        } else {
            selectAllButton.setImage(R.image.checkmark_off(), for: .normal)
        }
    }
}

extension SubjectPickerViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let detail = dataSource[indexPath.row]
        let isSelected = selectedIds.contains(detail.id)
        let model = SubjectPickerTableViewCellModel(details: detail, isSelected: isSelected)
        return tableView.dequeueReusableCell(withModel: model, for: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SubjectPickerTableViewCell else {
            return
        }
        let detail = dataSource[indexPath.row]
        let isSelected = selectedIds.contains(detail.id)
        let model = SubjectPickerTableViewCellModel(details: detail, isSelected: !isSelected)
        if isSelected {
            selectedIds.remove(detail.id)
        } else {
            selectedIds.insert(detail.id)
        }
        model.setup(cell: cell)
        updateSelectAllButton()
    }
}