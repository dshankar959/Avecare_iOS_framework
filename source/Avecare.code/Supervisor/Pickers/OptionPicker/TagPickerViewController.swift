import Foundation
import UIKit


extension TagPickerTableViewCellModel {
    init(option: RLMOptionValue, isSelected: Bool) {
        self.optionName = option.text
        self.isSelected = isSelected
    }
}

class TagPickerViewController: UIViewController {
    @IBOutlet weak var selectAllButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    let storage = DocumentService()

    var onDone: (([Int]) -> Void)?

    var dataSource: [RLMOptionValue] = [RLMOptionValue]()

    var selectedValues = Set<Int>()

    var isSelectedAll: Bool {
        return dataSource.count == selectedValues.count
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func selectAllButtonTouched(_ sender: UIButton) {
        if isSelectedAll {
            selectedValues.removeAll()
        } else {
            selectedValues = Set(dataSource.map({ $0.value}))
        }
        tableView.reloadData()
        updateSelectAllButton()
    }

    @IBAction func doneButtonTouched(_ sender: UIButton) {
        dismiss(animated: true)
        onDone?(Array(selectedValues).sorted())
    }

    private func updateSelectAllButton() {
        if isSelectedAll {
            selectAllButton.setImage(R.image.checkmark_on(), for: .normal)
        } else {
            selectAllButton.setImage(R.image.checkmark_off(), for: .normal)
        }
    }
}

extension TagPickerViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = dataSource[indexPath.row]
        let isSelected = selectedValues.contains(option.value)
        let model = TagPickerTableViewCellModel(option: option, isSelected: isSelected)
        return tableView.dequeueReusableCell(withModel: model, for: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TagPickerTableViewCell else {
            return
        }
        let option = dataSource[indexPath.row]
        let isSelected = selectedValues.contains(option.value)
        let model = TagPickerTableViewCellModel(option: option, isSelected: !isSelected)
        if isSelected {
            selectedValues.remove(option.value)
        } else {
            selectedValues.insert(option.value)
        }
        model.setup(cell: cell)
        updateSelectAllButton()
    }
}
