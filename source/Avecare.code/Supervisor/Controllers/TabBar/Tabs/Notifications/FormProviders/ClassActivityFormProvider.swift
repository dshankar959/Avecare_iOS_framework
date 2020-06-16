import Foundation
import UIKit

class ClassActivityFormProvider {

    let indexPath: IndexPath
    weak var delegate: NotificationTypeDataProviderDelegate?

    var selectedActivity: RLMActivity?
    var activityDate: Date?

    var activityDateString: String? {
        guard let date = activityDate else { return nil }
        return dateFormatter.string(from: date)
    }

    var activityInstructions: String?

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy / MM / dd"
        return formatter
    }()

    init(indexPath: IndexPath) {
        self.indexPath = indexPath
    }
}

extension ClassActivityFormProvider: FormProvider {
    
    func isPublishable() -> Bool {
        // TODO Add completeness check logic when syncing is implemented
        return false
    }
    
    func form() -> Form {
        var viewModels = [AnyCellViewModel]()

        let activityTypes = RLMActivity.findAll().filter { $0.isActive }
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
                    guard let pickerView = pickerView as? SingleValuePickerView<RLMActivity>? else { return }
                    let selectedValue = pickerView?.selectedValue
                    self?.selectedActivity = selectedValue
                    view.setTextValue(selectedValue?.description)
                }))

        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date

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
                }))

        viewModels.append(DoublePickerViewFormViewModel(leftPicker: left, rightPicker: right))

        viewModels.append(MarginFormViewModel(height: 20))

        // swiftlint:disable line_length
        viewModels.append(InputTextFormViewModel(title: NSLocalizedString("notification_inspections_and_drills_special_instruction_title", comment: ""),
                                                 placeholder: NSLocalizedString("notification_inspections_and_drills_special_instruction_placeholder", comment: ""),
                                                 value: activityInstructions) { [weak self] _, textValue in
            self?.activityInstructions = textValue
        })
        // swiftlint:enable line_length

        return Form(viewModels: viewModels)
    }
}
