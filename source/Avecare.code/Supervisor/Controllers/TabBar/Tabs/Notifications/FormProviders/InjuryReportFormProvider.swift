import Foundation
import UIKit


class InjuryReportFormProvider {

    var injurySubjects = [RLMSubject]()
    var injuryDate: Date?
    var seletctedInjuryType: RLMInjury?

    var injuryDateString: String? {
        guard let date = injuryDate else { return nil }
        return Date.timeFormatter.string(from: date)
    }

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
        controller.selectedIds = Set(injurySubjects.map({ $0.id }))
        controller.onDone = { [weak self] details in
            self?.injurySubjects = Array(details)
            if let indexPath = self?.indexPath {
                self?.delegate?.didUpdateModel(at: indexPath)
            }
        }
        delegate?.present(controller, animated: true)
    }

    func deleteSubjectAt(_ index: Int) {
        injurySubjects.remove(at: index)
        delegate?.didUpdateModel(at: indexPath)
    }
}

extension InjuryReportFormProvider: FormProvider {
    func form() -> Form {
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
                }))

        var viewModels = [AnyCellViewModel]()
        viewModels.append(DoublePickerViewFormViewModel(leftPicker: left, rightPicker: right))
        if injurySubjects.count > 0 {
            viewModels.append(TagListFormViewModel(tags: injurySubjects.map({ "\($0.firstName), \($0.lastName)" }), deleteAction: deleteSubjectAt))
        }

        viewModels.append(InfoMessageFormViewModel(title: NSLocalizedString("notification_injury_report_message_description_title", comment: ""),
                                                   message: NSLocalizedString("notification_injury_report_message_description_text", comment: "")))

        let injuryTypes = RLMInjury.findAll().filter { $0.isActive }
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
                }))
        viewModels.append(PickerViewWithSideTitleFormViewModel(title: injuryPickerTitle, picker: injuryPicker))
        viewModels.append(InputTextFormViewModel(title: NSLocalizedString("notification_injury_report_additional_message_title", comment: ""),
                                                 placeholder: NSLocalizedString("notification_injury_report_additional_message_placeholder", comment: ""),
                                                 value: additionalMessage,
                onChange: { [weak self] (_, textValue) in
                    self?.additionalMessage = textValue
        }))

        return Form(viewModels: viewModels)
    }
}
