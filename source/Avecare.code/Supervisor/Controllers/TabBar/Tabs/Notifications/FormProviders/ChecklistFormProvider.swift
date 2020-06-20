import Foundation
import UIKit



protocol FormProvider {
    func form() -> Form
    func isPublishable() -> Bool
}


class ChecklistFormProvider {

    var completedTasks = Set<String>()

    let indexPath: IndexPath
    weak var delegate: NotificationTypeDataProviderDelegate?

    private let SavedDateKey = "{saved_date}"

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

    func isPublishable() -> Bool {
        // TODO Add completeness check logic when syncing is implemented
        return false
    }

    func form() -> Form {
        var subtitleString = NSLocalizedString("notification_daily_checklist_saved_date", comment: "")
        subtitleString = subtitleString.replacingOccurrences(of: SavedDateKey, with: "June 15, 3:16 PM")
        var models: [AnyCellViewModel] = [
            LabelFormViewModel.title(NSLocalizedString("notification_daily_checklist_title", comment: "")),
            LabelFormViewModel.subtitle(subtitleString)
                    .inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0))
        ]

        let availableTasks = RLMDailyTask.findAll().filter { $0.isActive }

        models += availableTasks.map { task in
            let isCompleted = completedTasks.contains(task.id) == true
            return CheckmarkFormViewModel(title: task.name, isChecked: isCompleted, onClick: { [weak self] in
                self?.completeTask(task.id)
            })
        }

        return Form(viewModels: models)
    }
}
