import UIKit
import CocoaLumberjack



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

    func didUpdateModel() {
        delegate?.didUpdateModel(at: indexPath)
    }

    var dailyTaskForm: RLMDailyTaskForm {
        // Collect saved dailyTasks and sort by last updated.
        let allDailyTaskForms = RLMDailyTaskForm.findAll()
        let sortedForms = RLMDailyTaskForm.sortObjectsByLastUpdated(order: .orderedAscending, allDailyTaskForms)

        // Use the most recent form.
        if let dailyTaskForm = sortedForms.last {
            if let clientLastUpdated = dailyTaskForm.clientLastUpdated {
                if Calendar.current.isDateInToday(clientLastUpdated) {
                    return dailyTaskForm
                }
            } else if let serverLastUpdated = dailyTaskForm.serverLastUpdated,
                Calendar.current.isDateInToday(serverLastUpdated) {
                RLMDailyTaskForm.writeTransaction {
                    dailyTaskForm.clientLastUpdated = Date()
                }
                return dailyTaskForm
            }
        }

        DDLogDebug("🆕 Adding new daily task form.")
        let dailyTaskForm = RLMDailyTaskForm(id: newUUID)
        dailyTaskForm.clientLastUpdated = Date()
        let availableTasks = RLMDailyTaskOption.findAll().filter { $0.isActive }
        for task in availableTasks {
            let dailyTask = RLMDailyTask()
            dailyTask.dailyTaskOption = task
            dailyTask.completed = false
            dailyTaskForm.tasks.append(dailyTask)
        }

        dailyTaskForm.create()
        return dailyTaskForm
    }
}


extension ChecklistFormProvider: FormProvider {

    func isPublishable() -> Bool {
        return dailyTaskForm.publishState == .local
    }

    func form() -> Form {
        var subtitleString: String

        if dailyTaskForm.publishState == .local {
            subtitleString = NSLocalizedString("notification_daily_checklist_saved_date", comment: "")
        } else {
            subtitleString = NSLocalizedString("notification_daily_checklist_published_date", comment: "")
        }

        let dateString = Date.fullMonthTimeFormatter.string(from: dailyTaskForm.clientLastUpdated ?? Date())
        subtitleString = subtitleString.replacingOccurrences(of: SavedDateKey, with: dateString)

        var models: [AnyCellViewModel] = [
            LabelFormViewModel.title(NSLocalizedString("notification_daily_checklist_title", comment: "")),
            LabelFormViewModel.subtitle(subtitleString)
                    .inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0))
        ]

        let isSubmitted = dailyTaskForm.publishState != .local

        models += dailyTaskForm.tasks.sorted(by: {
                guard let order0 = $0.dailyTaskOption?.order else { return false }
                guard let order1 = $1.dailyTaskOption?.order else { return false }
                return order0 < order1
            }).map { task in
            return CheckmarkFormViewModel(isEditable: !isSubmitted,
                                          title: task.dailyTaskOption?.name ?? "",
                                          isChecked: task.completed,
                                          onClick: { [weak self] in
                RLMDailyTaskForm.writeTransaction {
                    task.completed = !task.completed
                    self?.dailyTaskForm.clientLastUpdated = Date()
                }

                self?.didUpdateModel()
            })
        }

        return Form(viewModels: models)
    }
}
