import Foundation
import UIKit


class InjuryReportFormProvider {

    var injurySubjects = [RLMSubject]()
    var injuryDate: Date?

    var injuryDateString: String? {
        guard let date = injuryDate else { return nil }
        return Date.timeFormatter.string(from: date)
    }

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
        let left = PickerViewFormViewModel(title: "Select Child", placeholder: "Add a child", accessory: .plus, textValue: nil,
                action: .init(onClick: { [weak self] view in
                    self?.showSubjectPicker()
                }, inputView: nil, onInput: nil))

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.backgroundColor = .white

        let right = PickerViewFormViewModel(title: "Select Time", placeholder: "12:00pm", accessory: .clock, textValue: injuryDateString,
                action: .init(onClick: { [weak self] view in
                    if let date = self?.injuryDate {
                        datePicker.date = date
                    }
                    view.becomeFirstResponder()
                }, inputView: datePicker, onInput: { [weak self] view, datePicker in
                    guard let datePicker = datePicker as? UIDatePicker else {
                        return
                    }
                    self?.injuryDate = datePicker.date
                    view.setTextValue(self?.injuryDateString)
                }))

        // swiftlint:disable line_length
        let text = "Your child may have experienced a mild bump, scrape, or bite. This is NOT an emergency. Please connect with your child’s educator upon pick up."
        // swiftlint:enable line_length

        var viewModels = [AnyCellViewModel]()
        viewModels.append(DoublePickerViewFormViewModel(leftPicker: left, rightPicker: right))
        if injurySubjects.count > 0 {
            viewModels.append(TagListFormViewModel(tags: injurySubjects.map({ "\($0.firstName), \($0.lastName)" }), deleteAction: deleteSubjectAt))
        }
        viewModels.append(InfoMessageFormViewModel(title: "Message Description:", message: text))

        return Form(viewModels: viewModels)
    }
}
