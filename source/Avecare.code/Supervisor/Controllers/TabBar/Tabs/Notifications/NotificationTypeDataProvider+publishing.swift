import Foundation
import CocoaLumberjack

extension DefaultNotificationTypeDataProvider {

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
