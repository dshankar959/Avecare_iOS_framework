import UIKit



extension SubjectDetailsTagsViewModel {

    init(row: RLMLogTagsRow, isEditable: Bool) {
        icon = UIImage(named: row.iconName)
        iconColor = UIColor(rgb: row.iconColor)
        title = row.title
        selectOptionTitle = row.placeholder
        self.isEditable = isEditable
    }
}

extension SubjectListDataProvider {

    func viewModel(for row: RLMLogTagsRow,
                   editable: Bool,
                   at indexPath: IndexPath,
                   for rowIndex: Int,
                   updateCallback: @escaping (Date) -> Void) -> AnyCellViewModel {

        var tagsModel = SubjectDetailsTagsViewModel(row: row, isEditable: editable)

        tagsModel.action = { [weak self] view in
            self?.showTagPicker(from: view, row: row, at: indexPath, updateCallback: updateCallback)
        }

        tagsModel.deleteAction = { [weak self] index in
            RLMLogTagsRow.writeTransaction {
                row.selectedValues.remove(at: index)
            }
            self?.delegate?.didUpdateModel(at: indexPath)
        }

        tagsModel.onRemoveCell = { [weak self] in
            if let subject = self?.selectedSubject {
                RLMLogForm.writeTransaction {
                    subject.todayForm.rows.remove(at: rowIndex)
                }
                self?.delegate?.didUpdateModel(at: indexPath)
            }
        }

        if row.selectedValues.count > 0 {
            let options = Array(row.options)
            var selectedOptions = [RLMOptionValue]()
            for option in options {
                if row.selectedValues.contains(option.value) {
                    selectedOptions.append(option)
                }
            }
            tagsModel.selectedOptions = selectedOptions
        } else {
            tagsModel.selectedOptions.removeAll()
        }

        return tagsModel
    }

    private func showTagPicker(from view: SubjectDetailsTagsView,
                               row: RLMLogTagsRow,
                               at indexPath: IndexPath,
                               updateCallback: @escaping (Date) -> Void) {
        guard let controller = R.storyboard.tagPickerViewController().instantiateInitialViewController() as? TagPickerViewController else {
                return
        }
        controller.dataSource = Array(row.options)
        controller.selectedValues = Set(row.selectedValues)
        controller.onDone = { [weak self] values in
            RLMLogTagsRow.writeTransaction {
                row.selectedValues.removeAll()
                row.selectedValues.append(objectsIn: values)
            }
            updateCallback(Date())
            self?.delegate?.didUpdateModel(at: indexPath)
        }
        delegate?.present(controller, animated: true)
    }
}
