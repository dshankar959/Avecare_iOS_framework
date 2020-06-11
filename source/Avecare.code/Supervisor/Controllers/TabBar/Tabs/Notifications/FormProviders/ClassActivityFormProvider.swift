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
    private func inputTextViewModel() -> InputTextFormViewModel {
        let viewModel = InputTextFormViewModel(title: "Special Instructions (if any)",
                placeholder: "140 characters maximum.", value: activityInstructions) { [weak self] _, textValue in
            self?.activityInstructions = textValue
        }

        return viewModel
    }

    func form() -> Form {
        let activityTypes = RLMActivity.findAll().filter { $0.isActive }
        let activityTypePicker = SingleValuePickerView(values: activityTypes)
        activityTypePicker.backgroundColor = .white

        let left = PickerViewFormViewModel(title: "Select Activity",
                                           placeholder: "No activity selected",
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

        let right = PickerViewFormViewModel(title: "Select Date",
                                            placeholder: "19 / 10 / 10",
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

        return Form(viewModels: [
                DoublePickerViewFormViewModel(leftPicker: left, rightPicker: right),
                inputTextViewModel()
            ])

    }
}
