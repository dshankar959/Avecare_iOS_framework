import Foundation
import UIKit

class ClassActivityFormProvider {

    enum State {
        case new
        case error(err: Error)
        case loading
        case loaded(activities: [UnitActivity])
    }
    var state = State.new

    let indexPath: IndexPath
    weak var delegate: NotificationTypeDataProviderDelegate?

    var selectedActivity: UnitActivity?
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

    private func selectActivityViewModel(values: [UnitActivity]?) -> PickerViewFormViewModel {
        var viewModel = PickerViewFormViewModel(title: "Select Activity", placeholder: "No activity selected",
                accessory: .dropdown, textValue: selectedActivity?.description, action: nil)

        if let values = values {
            let picker = SingleValuePickerView(values: values)
            picker.backgroundColor = .white

            viewModel.action = PickerViewFormViewModel.Action(onClick: { [weak self] view in
                picker.selectedValue = self?.selectedActivity
                view.becomeFirstResponder()
            }, inputView: picker, onInput: { [weak self] view, pickerView in
                guard let pickerView = pickerView as? SingleValuePickerView<UnitActivity>? else { return }
                let selectedValue = pickerView?.selectedValue
                self?.selectedActivity = selectedValue
                view.setTextValue(selectedValue?.description)
            })
        }
        return viewModel
    }

    private func selectDateViewModel() -> PickerViewFormViewModel {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date

        let right = PickerViewFormViewModel(title: "Select Date", placeholder: "19 / 10 / 10", accessory: .calendar, textValue: activityDateString,
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
        return right
    }

    func form() -> Form {
        switch state {
        case .new:
            guard let id = appDelegate._session.unitDetails?.id else {
                state = .error(err: AuthError.unitNotFound.message)
                return form()
            }

            UnitAPIService.getActivities(id: id) { [weak self] result in
                switch result {
                case .success(let activities):
                    self?.state = .loaded(activities: activities.filter({ $0.isActive }))
                case .failure(let error):
                    self?.state = .error(err: error)
                }

                if let indexPath = self?.indexPath {
                    self?.delegate?.didUpdateModel(at: indexPath)
                }
            }

            state = .loading
            return form()
        case .error(let error):
            //TODO: error
            return Form(viewModels: [])
        case .loading:
            return Form(viewModels: [])
        case .loaded(let activities):
            return Form(viewModels: [
                DoublePickerViewFormViewModel(leftPicker: selectActivityViewModel(values: activities), rightPicker: selectDateViewModel()),
                inputTextViewModel()
            ])
        }

    }
}
