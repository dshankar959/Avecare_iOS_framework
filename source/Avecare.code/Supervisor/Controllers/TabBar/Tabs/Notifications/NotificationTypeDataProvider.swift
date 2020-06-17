import Foundation
import CocoaLumberjack
import UIKit



protocol NotificationTypeDataProvider: class {
    var numberOfRows: Int { get }
    func model(for indexPath: IndexPath) -> NotificationTypeTableViewCellModel
    func loadForm(at indexPath: IndexPath) -> Form
    func setSelected(_ isSelected: Bool, at indexPath: IndexPath)
    func navigationItems(at indexPath: IndexPath, type: NotificationType) -> [DetailsNavigationView.Item]
}

protocol NotificationTypeDataProviderDelegate: UIViewController {
    func showAlert(title: String, message: String)
    func didUpdateModel(at indexPath: IndexPath)
}

class DefaultNotificationTypeDataProvider: NotificationTypeDataProvider {
    
    private var lastSelectedIndexPath: IndexPath?
    weak var delegate: NotificationTypeDataProviderDelegate?

    weak var presentationController: UIViewController?

    var dataSource = [
        NotificationTypeTableViewCellModel(icon: R.image.checklistIcon(),
                                           color: R.color.blueIcon(),
                                           title: NSLocalizedString("notification_menu_title_daily_checklist", comment: ""),
                                           type: .dailyCheckList),
        NotificationTypeTableViewCellModel(icon: R.image.classActivityIcon(),
                                           color: R.color.blueIcon(),
                                           title: NSLocalizedString("notification_menu_title_inspections_and_drills", comment: ""),
                                           type: .classActivity),
        NotificationTypeTableViewCellModel(icon: R.image.exclamationIcon(),
                                           color: R.color.redIcon(),
                                           title: NSLocalizedString("notification_menu_title_injury_report", comment: ""),
                                           type: .injuryReport),
        NotificationTypeTableViewCellModel(icon: R.image.clockIcon(),
                                           color: R.color.blueIcon(),
                                           title: NSLocalizedString("notification_menu_title_reminder", comment: ""),
                                           type: .reminders)
    ]

    //0
    lazy var checklistDataProvider: ChecklistFormProvider = {
        let provider = ChecklistFormProvider(indexPath: IndexPath(row: 0, section: 0))
        provider.delegate = delegate
        return provider
    }()

    //1
    lazy var classActivityFormProvider: ClassActivityFormProvider = {
       let provider = ClassActivityFormProvider(indexPath: IndexPath(row: 1, section: 0))
        provider.delegate = delegate
        return provider
    }()

    //2
    lazy var injuryFormProvider: InjuryReportFormProvider = {
        let provider = InjuryReportFormProvider(indexPath: IndexPath(row: 2, section: 0))
        provider.delegate = delegate
        return provider
    }()

    //3
    lazy var reminderFormProvider: RemindersFormProvider = {
        let provider = RemindersFormProvider(indexPath: IndexPath(row: 3, section: 0))
        provider.delegate = delegate
        return provider
    }()

    var numberOfRows: Int {
        return dataSource.count
    }

    func model(for indexPath: IndexPath) -> NotificationTypeTableViewCellModel {
        return dataSource[indexPath.row]
    }

    func setSelected(_ isSelected: Bool, at indexPath: IndexPath) {
        if isSelected {
            if let last = lastSelectedIndexPath {
                if last != indexPath {
                    // deselect
                    dataSource[last.row].isSelected = false
                    delegate?.didUpdateModel(at: last)
                } else {
                    // already selected
                    return
                }
            }
            dataSource[indexPath.row].isSelected = isSelected
            lastSelectedIndexPath = indexPath
            delegate?.didUpdateModel(at: indexPath)
        } else {
            guard let last = lastSelectedIndexPath, last == indexPath else {
                return
            }
            dataSource[last.row].isSelected = false
            delegate?.didUpdateModel(at: last)
        }
    }

    func loadForm(at indexPath: IndexPath) -> Form {
        switch indexPath.row {
        case 0: return checklistDataProvider.form()
        case 1: return classActivityFormProvider.form()
        case 2: return injuryFormProvider.form()
        case 3: return reminderFormProvider.form()
        default: return Form(viewModels: [])
        }
    }

    func navigationItems(at indexPath: IndexPath, type: NotificationType) -> [DetailsNavigationView.Item] {
        var isEnabled = false
        switch type {
        case .reminders: isEnabled = reminderFormProvider.isPublishable()
        case .injuryReport: isEnabled = injuryFormProvider.isPublishable()
        default: break
        }

        let publishText = NSLocalizedString("send_button_title", comment: "")
        let publishColor = isEnabled ? R.color.main() :R.color.lightText4()

        return [
            .button(options: .init(action: { [weak self] view, options, index in
                self?.publishNotification(type: type)
            }, isEnabled: isEnabled, text: publishText, textColor: R.color.mainInversion(),
                    tintColor: publishColor, cornerRadius: 4))
        ]
    }

    func publishNotification(type: NotificationType) {
        switch type {
        case .reminders:
            createReminderandPublish()
        case .injuryReport:
            createInjuryReport()

        default:
            // TODO add logic for publishing other notif types
            break
        }
    }

    func createInjuryReport() {
        var dSource = [RLMInjury]()
        for subject in injuryFormProvider.injurySubjects {
            let injury = RLMInjury(id: newUUID)
            injury.message = injuryFormProvider.additionalMessage
            injury.rawPublishState = 1
            injury.subject = subject
            injury.timeOfInjury = injuryFormProvider.injuryDate
            injury.injuryOption = injuryFormProvider.seletctedInjuryType
            dSource.insert(injury, at: 0)
            RLMInjury.createOrUpdateAll(with: dSource, update: false)
        }
        publishInjuries(injuries: dSource)
        self.injuryFormProvider.clearAll()
        self.delegate?.showAlert(title: NSLocalizedString("notification_sent_title", comment: ""),
                                                          message: NSLocalizedString("injury_notification_sent_message", comment: ""))
    }

    func publishInjuries(injuries: [RLMInjury]) {
        UnitAPIService.publishInjuries(data: injuries, completion: { result in
            switch result {
            case .success(let publishedInjuries):
                for injury in publishedInjuries {
                    injury.publishState = .published
                }
                RLMInjury.createOrUpdateAll(with: publishedInjuries, update: true)
            case .failure(let error):
                DDLogError("\(error)")
            }
        })
    }


    func createReminderandPublish() {
        var dSource = [RLMReminder]()
        for subject in reminderFormProvider.subjects {
            let reminder = RLMReminder(id: newUUID)
            reminder.message = reminderFormProvider.additionalMessage
            reminder.rawPublishState = 1
            reminder.subject = subject
            reminder.reminderOption = reminderFormProvider.selectedReminder
            dSource.insert(reminder, at: 0)
            RLMReminder.createOrUpdateAll(with: dSource, update: false)
        }
        publishReminders(reminders: dSource)
        self.reminderFormProvider.clearAll()
        self.delegate?.showAlert(title: NSLocalizedString("notification_sent_title", comment: ""),
                                                          message: NSLocalizedString("reminder_notification_sent_message", comment: ""))
    }

    func publishReminders(reminders: [RLMReminder]) {

        UnitAPIService.publishReminders(data: reminders, completion: { result in
            switch result {
            case .success(let publishedReminders):
                for reminder in publishedReminders {
                    reminder.publishState = .published
                }
                RLMReminder.createOrUpdateAll(with: publishedReminders, update: true)
            case .failure(let error):
                DDLogError("\(error)")
            }
        })
    }
}
