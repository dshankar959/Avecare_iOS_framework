import Foundation
import UIKit


class InjuryReportFormProvider {

    var injurySubjects = [RLMSubject]()
    var injuryDate: Date?
    var seletctedInjuryType: RLMInjuryOption?

    var injuryDateString: String? {
        guard let date = injuryDate else { return nil }
        return Date.timeFormatter.string(from: date)
    }

    func updatePublishableState() {
        self.delegate?.didUpdateModel(at: self.indexPath)
    }

    let indexPath: IndexPath
    weak var delegate: NotificationTypeDataProviderDelegate?

    var additionalMessage: String = ""

    init(indexPath: IndexPath) {
        self.indexPath = indexPath
    }

    func showSubjectPicker() {
        guard let controller = R.storyboard.subjectPickerViewController()
                .instantiateInitialViewController() as? SubjectPickerViewController else {
            return
        }
        controller.selectedIds = Set(injurySubjects.map({ $0.id }))
        controller.onDone = { [weak self] details in
            self?.injurySubjects = Array(details)
            self?.updatePublishableState()
        }
        delegate?.present(controller, animated: true)
    }

    func deleteSubjectAt(_ index: Int) {
        injurySubjects.remove(at: index)
        self.updatePublishableState()
    }
}

extension InjuryReportFormProvider: FormProvider {

    func isPublishable() -> Bool {
        return !(injurySubjects.count == 0 || injuryDate == nil || seletctedInjuryType == nil)
    }

    func form() -> Form {
        var viewModels = [AnyCellViewModel]()

        let left = PickerViewFormViewModel(title: NSLocalizedString("notification_injury_report_select_child_title", comment: ""),
                                           placeholder: NSLocalizedString("notification_injury_report_select_child_placeholder", comment: ""),
                                           accessory: .plus,
                                           textValue: nil,
                action: .init(onClick: { [weak self] view in
                    self?.showSubjectPicker()
                }, inputView: nil, onInput: nil))

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.backgroundColor = .white

        let right = PickerViewFormViewModel(title: NSLocalizedString("notification_injury_report_select_time_title", comment: ""),
                                            placeholder: NSLocalizedString("notification_injury_report_select_time_placeholder", comment: ""),
                                            accessory: .clock,
                                            textValue: injuryDateString,
                action: .init(onClick: { [weak self] view in
                    if let date = self?.injuryDate {
                        datePicker.date = date
                    }
                    view.becomeFirstResponder()
                }, inputView: datePicker, onInput: { [weak self] view, datePicker in
                    guard let datePicker = datePicker as? UIDatePicker else { return }
                    self?.injuryDate = datePicker.date
                    view.setTextValue(self?.injuryDateString)
                    self?.updatePublishableState()
                }))

        viewModels.append(DoublePickerViewFormViewModel(leftPicker: left, rightPicker: right))

        if injurySubjects.count > 0 {
            viewModels.append(MarginFormViewModel(height: 20))

            viewModels.append(TagListFormViewModel(tags: injurySubjects.map({ "\($0.firstName), \($0.lastName)" }), deleteAction: deleteSubjectAt))
        }

        viewModels.append(MarginFormViewModel(height: 20))

        viewModels.append(InfoMessageFormViewModel(title: NSLocalizedString("notification_injury_report_message_description_title", comment: ""),
                                                   message: NSLocalizedString("notification_injury_report_message_description_text", comment: "")))

        let injuryTypes = RLMInjuryOption.findAll().filter { $0.isActive }
        let injuryTypePicker = SingleValuePickerView(values: injuryTypes)
        injuryTypePicker.backgroundColor = .white

        let injuryPickerTitle = NSLocalizedString("notification_injury_report_select_injury_title", comment: "")
        let injuryPicker = PickerViewFormViewModel(title: nil,
                                                   placeholder: NSLocalizedString("notification_injury_report_select_injury_placeholder", comment: ""),
                                                   accessory: .dropdown,
                                                   textValue: seletctedInjuryType?.name,
                action: .init(onClick: { [weak self] view in
                    injuryTypePicker.selectedValue = self?.seletctedInjuryType
                    view.becomeFirstResponder()
                }, inputView: injuryTypePicker, onInput: { [weak self] view, _ in
                    self?.seletctedInjuryType = injuryTypePicker.selectedValue
                    view.setTextValue(self?.seletctedInjuryType?.name)
                    self?.updatePublishableState()
                }))

        viewModels.append(PickerViewWithSideTitleFormViewModel(title: injuryPickerTitle, picker: injuryPicker))

        viewModels.append(MarginFormViewModel(height: 20))

        viewModels.append(InputTextFormViewModel(title: NSLocalizedString("notification_injury_report_additional_message_title", comment: ""),
                                                 placeholder: NSLocalizedString("notification_injury_report_additional_message_placeholder", comment: ""),
                                                 value: additionalMessage,
                onChange: { [weak self] (_, textValue) in
                    self?.additionalMessage = textValue ?? ""
        }))

        return Form(viewModels: viewModels)
    }

    func clearAll() {
        injurySubjects.removeAll()
        injuryDate = nil
        additionalMessage = ""
        seletctedInjuryType = nil
        updatePublishableState()
    }
}
