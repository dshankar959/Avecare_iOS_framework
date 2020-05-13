import Foundation
import UIKit



protocol FormProvider {
    func form() -> Form
}


class ChecklistFormProvider {

    enum State {
        case new
        case error(err: Error)
        case loading
        case loaded(tasks: [DailyTask])
    }
    var state = State.new

    var completedTasks = Set<String>()

    let indexPath: IndexPath
    weak var delegate: NotificationTypeDataProviderDelegate?

    init(indexPath: IndexPath) {
        self.indexPath = indexPath
    }

    func completeTask(_ id: String) {
        if completedTasks.contains(id) {
            completedTasks.remove(id)
        } else {
            completedTasks.insert(id)
        }
        delegate?.didUpdateModel(at: indexPath)
    }
}


extension ChecklistFormProvider: FormProvider {
    func form() -> Form {
        switch state {
        case .new:

            guard let unitId = RLMSupervisor.details?.primaryUnitId else {
                state = .error(err: AuthError.unitNotFound.message)
                return form()
            }

            guard let id = RLMUnit.details(for: unitId)?.id else {
                state = .error(err: AuthError.unitNotFound.message)
                return form()
            }

            UnitAPIService.getDailyTasks(unitId: id) { [weak self] result in
                switch result {
                case .success(let tasks):
                    self?.state = .loaded(tasks: tasks)
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
            //TODO: error form view
            return Form(viewModels: [])
        case .loading:
            //TODO: loading form view
            return Form(viewModels: [])
        case .loaded(let tasks):
            var models: [AnyCellViewModel] = [
                FormLabelViewModel.title("Today's Checklist"),
                FormLabelViewModel.subtitle("Last saved - Jan 5, 7:16 AM")
                        .inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0))
            ]

            models += tasks.map { task in
                let isCompleted = completedTasks.contains(task.id) == true
                return CheckmarkFormViewModel(id: task.id, title: task.description, isChecked: isCompleted, onClick: completeTask)
            }

            return Form(viewModels: models)
        }
    }

}
