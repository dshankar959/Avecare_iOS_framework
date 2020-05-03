import Foundation
import UIKit

class RemindersFormProvider {
    enum State {
        case new
        case error(err: Error)
        case loading
        case loaded(reminders: [UnitReminder])
    }
    var state = State.new
    var subjects = [RLMSubject]()
    var selectedReminder: UnitReminder?

    let indexPath: IndexPath
    weak var delegate: NotificationTypeDataProviderDelegate?

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
        switch state {
        case .new:
            guard let id = appDelegate._session.unitDetails?.id else {
                state = .error(err: AuthError.unitNotFound.message)
                return form()
            }

            UnitAPIService.getReminders(id: id) { [weak self] result in
                switch result {
                case .success(let reminders):
                    self?.state = .loaded(reminders: reminders.filter({ $0.isActive }))
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
        case .loaded(let reminders):
            let left = PickerViewFormViewModel(title: "Select Student", placeholder: "Add a student", accessory: .plus, textValue: nil,
                    action: .init(onClick: { [weak self] view in
                        self?.showSubjectPicker()
                    }, inputView: nil, onInput: nil))

            let pickerView = SingleValuePickerView(values: reminders)
            pickerView.backgroundColor = .white

            let right = PickerViewFormViewModel(title: "Select Reminder", placeholder: "No reminder selected", accessory: .dropdown,
                    textValue: selectedReminder?.description, action: .init(onClick: { [weak self] view in
                pickerView.selectedValue = self?.selectedReminder
                view.becomeFirstResponder()
            }, inputView: pickerView, onInput: { [weak self] view, _ in
                let selectedValue = pickerView.selectedValue
                self?.selectedReminder = selectedValue
                view.setTextValue(selectedValue?.description)
            }))

            var viewModels: [AnyCellViewModel] = [DoublePickerViewFormViewModel(leftPicker: left, rightPicker: right)]
            if subjects.count > 0 {
                viewModels.append(TagListFormViewModel(tags: subjects.map({ "\($0.firstName), \($0.lastName)" }), deleteAction: deleteSubjectAt))
            }

            return Form(viewModels: viewModels)
        }
    }
}
