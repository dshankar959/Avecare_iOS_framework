import UIKit



class RemindersFormProvider {

    var subjects = [RLMSubject]()
    var selectedReminder: RLMReminder?

    let indexPath: IndexPath
    weak var delegate: NotificationTypeDataProviderDelegate?

    var additionalMessage: String?

    init(indexPath: IndexPath) {
        self.indexPath = indexPath
    }

    func showSubjectPicker() {
        guard let controller = R.storyboard.subjectPickerViewController()
                .instantiateInitialViewController() as? SubjectPickerViewController else {
            return
        }
        controller.selectedIds = Set(subjects.map({ $0.id }))
        controller.onDone = { [weak self] details in
            self?.subjects = Array(details)
            if let indexPath = self?.indexPath {
                self?.delegate?.didUpdateModel(at: indexPath)
            }
        }
        delegate?.present(controller, animated: true)
    }

    func deleteSubjectAt(_ index: Int) {
        subjects.remove(at: index)
        delegate?.didUpdateModel(at: indexPath)
    }

}



extension RemindersFormProvider: FormProvider {

    func form() -> Form {
        let left = PickerViewFormViewModel(title: NSLocalizedString("notification_reminder_select_child_title", comment: ""),
                                           placeholder: NSLocalizedString("notification_reminder_select_child_placeholder", comment: ""),
                                           accessory: .plus,
                                           textValue: nil,
                action: .init(onClick: { [weak self] view in
                    self?.showSubjectPicker()
                }, inputView: nil, onInput: nil))

        let reminderTypes = RLMReminder.findAll().filter { $0.isActive }
        let reminderTypePickerView = SingleValuePickerView(values: reminderTypes)
        reminderTypePickerView.backgroundColor = .white

        let right = PickerViewFormViewModel(title: NSLocalizedString("notification_reminder_select_reminder_title", comment: ""),
                                            placeholder: NSLocalizedString("notification_reminder_select_reminder_placeholder", comment: ""),
                                            accessory: .dropdown,
                                            textValue: selectedReminder?.description,
                action: .init(onClick: { [weak self] view in
                    reminderTypePickerView.selectedValue = self?.selectedReminder
                    view.becomeFirstResponder()
                }, inputView: reminderTypePickerView, onInput: { [weak self] view, _ in
                    let selectedValue = reminderTypePickerView.selectedValue
                    self?.selectedReminder = selectedValue
                    view.setTextValue(selectedValue?.description)
                }))

        var viewModels: [AnyCellViewModel] = [DoublePickerViewFormViewModel(leftPicker: left, rightPicker: right)]

        if subjects.count > 0 {
            viewModels.append(MarginFormViewModel(height: 20))

            viewModels.append(TagListFormViewModel(tags: subjects.map({ "\($0.firstName), \($0.lastName)" }), deleteAction: deleteSubjectAt))
        }

        viewModels.append(MarginFormViewModel(height: 20))

        viewModels.append(InputTextFormViewModel(title: NSLocalizedString("notification_injury_report_additional_message_title", comment: ""),
                                                 placeholder: NSLocalizedString("notification_injury_report_additional_message_placeholder", comment: ""),
                                                 value: additionalMessage,
                onChange: { [weak self] (_, textValue) in
                    self?.additionalMessage = textValue
        }))

        return Form(viewModels: viewModels)
    }
}
