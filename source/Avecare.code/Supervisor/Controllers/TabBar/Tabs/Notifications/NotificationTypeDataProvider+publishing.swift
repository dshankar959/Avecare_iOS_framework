import Foundation
import CocoaLumberjack

extension DefaultNotificationTypeDataProvider {

    func publishNotification(type: NotificationType) {
        switch type {
        case .reminders:
            createReminderandPublish()
        case .injuryReport:
            createInjuryReport()
        case .classActivity:
            createClassActivity()
        case .dailyCheckList:
            completeDailyChecklist()
        }
    }

    func completeDailyChecklist() {

        let dailyTasks = checklistDataProvider.dailyTaskForm

        RLMDailyTaskForm.writeTransaction {
            dailyTasks.publishState = .publishing
        }

        self.delegate?.showAlert(title: NSLocalizedString("notification_daily_checklist_published_title", comment: ""),
        message: NSLocalizedString("notification_daily_checklist_published_message", comment: ""))

        self.checklistDataProvider.didUpdateModel()

        callSyncEngineUpdate()
    }

    func createClassActivity() {

        // Create Activity in DB with publishing status
        let activity = RLMActivity(id: newUUID)
        activity.activityDate = classActivityFormProvider.activityDate
        activity.activityOption = classActivityFormProvider.selectedActivity
        activity.unit = classActivityFormProvider.unit
        activity.instructions = classActivityFormProvider.activityInstructions
        activity.rawPublishState = 1
        RLMActivity.createOrUpdateAll(with: [activity], update: false)

        // Update UI for next entry
        classActivityFormProvider.clearAll()
        self.delegate?.showAlert(title: NSLocalizedString("notification_sent_title", comment: ""),
                                 message: NSLocalizedString("notification_activity_sent_message", comment: ""))

        callSyncEngineUpdate()
    }

    func createInjuryReport() {
        var dSource = [RLMInjury]()

        // Create Injuries in DB with publishing status
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

        // Update UI for next entry
        self.injuryFormProvider.clearAll()
        self.delegate?.showAlert(title: NSLocalizedString("notification_sent_title", comment: ""),
                                 message: NSLocalizedString("notification_injury_sent_message", comment: ""))

        callSyncEngineUpdate()
    }


    func createReminderandPublish() {
        var dSource = [RLMReminder]()

        // Create reminders in DB with publishing status
        for subject in reminderFormProvider.subjects {
            let reminder = RLMReminder(id: newUUID)
            reminder.message = reminderFormProvider.additionalMessage
            reminder.rawPublishState = 1
            reminder.subject = subject
            reminder.reminderOption = reminderFormProvider.selectedReminder
            dSource.insert(reminder, at: 0)
            RLMReminder.createOrUpdateAll(with: dSource, update: false)
        }

        // Update UI for next entry
        self.reminderFormProvider.clearAll()
        self.delegate?.showAlert(title: NSLocalizedString("notification_sent_title", comment: ""),
                                 message: NSLocalizedString("notification_reminder_sent_message", comment: ""))

        callSyncEngineUpdate()

    }

    func callSyncEngineUpdate() {
        // Silent Sync call
        syncEngine.syncAll { error in
            if let error = error {
                DDLogError("\(error)")
            }
        }
    }
}
