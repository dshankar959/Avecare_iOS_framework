import Foundation
import UIKit

class ClassActivityFormProvider {

    let indexPath: IndexPath
    weak var delegate: NotificationTypeDataProviderDelegate?

    var selectedActivity: RLMActivityOption?
    var activityDate: Date?
    var unit: RLMUnit?

    var activityDateString: String? {
        guard let date = activityDate else { return nil }
        return Date.monthDayYearFormatter.string(from: date)
    }

    var activityInstructions: String = ""

    init(indexPath: IndexPath) {
        self.indexPath = indexPath
    }

    func updatePublishableState() {
        self.delegate?.didUpdateModel(at: self.indexPath)
    }
}

extension ClassActivityFormProvider: FormProvider {

    func isPublishable() -> Bool {
        return !(activityDate == nil || selectedActivity == nil)
    }

    func form() -> Form {
        var viewModels = [AnyCellViewModel]()

        let activityTypes = RLMActivityOption.findAll().filter { $0.isActive }
        let activityTypePicker = SingleValuePickerView(values: activityTypes)
        activityTypePicker.backgroundColor = .white

        let left = PickerViewFormViewModel(title: NSLocalizedString("notification_inspections_and_drills_select_activity_title", comment: ""),
                                           placeholder: NSLocalizedString("notification_inspections_and_drills_select_activity_placetolder", comment: ""),
                                           accessory: .dropdown,
                                           textValue: selectedActivity?.name,
                action: .init(onClick: { [weak self] view in
                    activityTypePicker.selectedValue = self?.selectedActivity
                    view.becomeFirstResponder()
                }, inputView: activityTypePicker, onInput: { [weak self] view, pickerView in
                    guard let pickerView = pickerView as? SingleValuePickerView<RLMActivityOption>? else { return }
                    let selectedValue = pickerView?.selectedValue
                    self?.selectedActivity = selectedValue
                    view.setTextValue(selectedValue?.name)
                    self?.updatePublishableState()

                }))

        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()

        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }

        let right = PickerViewFormViewModel(title: NSLocalizedString("notification_inspections_and_drills_select_date_title", comment: ""),
                                            placeholder: NSLocalizedString("notification_inspections_and_drills_select_date_placeholder", comment: ""),
                                            accessory: .calendar,
                                            textValue: activityDateString,
                action: .init(onClick: { [weak self] view in
                    if let date = self?.activityDate {
                        datePicker.date = date
                    }
                    view.becomeFirstResponder()
                }, inputView: datePicker, onInput: { [weak self] view, datePicker in
                    guard let datePicker = datePicker as? UIDatePicker else { return }
                    self?.activityDate = datePicker.date
                    view.setTextValue(self?.activityDateString)
                    self?.updatePublishableState()
                }))

        viewModels.append(DoublePickerViewFormViewModel(leftPicker: left, rightPicker: right))
        viewModels.append(MarginFormViewModel(height: 20))

        // swiftlint:disable line_length
        viewModels.append(InputTextFormViewModel(title: NSLocalizedString("notification_inspections_and_drills_special_instruction_title", comment: ""),
                                                 placeholder: NSLocalizedString("notification_inspections_and_drills_special_instruction_placeholder", comment: ""),
                                                 value: activityInstructions,
        onChange: { [weak self] (_, textValue) in
            self?.activityInstructions = textValue ?? ""
            }))
        // swiftlint: enable line_length

        return Form(viewModels: viewModels)
    }

    func clearAll() {
        selectedActivity = nil
        activityDate = nil
        unit = nil
        activityInstructions = ""
        updatePublishableState()
    }
}
