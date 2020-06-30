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
        if let unitId = RLMSupervisor.details?.primaryUnitId {
            let dailyTasks = checklistDataProvider.dailyTaskForm

            RLMDailyTaskForm.writeTransaction {
                dailyTasks.publishState = .publishing
            }

            NotificationsAPIService.publishDailyTaskForm(unitId: unitId, data: dailyTasks) { [weak self] result in
                switch result {
                case .success(let publishedDailyTasks):
                    self?.delegate?.showAlert(title: NSLocalizedString("notification_daily_checklist_published_title", comment: ""),
                                             message: NSLocalizedString("notification_daily_checklist_published_message", comment: ""))
                    RLMDailyTaskForm.writeTransaction {
                        dailyTasks.serverLastUpdated = publishedDailyTasks.serverLastUpdated
                        dailyTasks.publishState = .published
                    }
                    self?.checklistDataProvider.didUpdateModel()
                case .failure(let error):
                    DDLogError("\(error)")

                    if error.userInfo.contains("already exist") {
                        RLMDailyTaskForm.writeTransaction {
                            dailyTasks.publishState = .published
                        }

                        self?.checklistDataProvider.didUpdateModel()
                        self?.delegate?.showAlert(title: NSLocalizedString("notification_daily_checklist_already_published_title", comment: ""),
                                                  message: NSLocalizedString("notification_daily_checklist_already_published_message", comment: ""))
                    }
                }
            }
        }
    }

    func createClassActivity() {
        let activity = RLMActivity(id: newUUID)
        activity.activityDate = classActivityFormProvider.activityDate
        activity.activityOption = classActivityFormProvider.selectedActivity
        activity.unit = classActivityFormProvider.unit
        activity.instructions = classActivityFormProvider.activityInstructions
        RLMActivity.createOrUpdateAll(with: [activity], update: false)
        classActivityFormProvider.clearAll()

        publsihActivity(activity: activity)
        self.delegate?.showAlert(title: NSLocalizedString("notification_sent_title", comment: ""),
                                 message: NSLocalizedString("notification_activity_sent_message", comment: ""))
    }

    func publsihActivity(activity: RLMActivity) {
        if let unitId = RLMSupervisor.details?.primaryUnitId {
            NotificationsAPIService.publishActivity(uintId: unitId, data: activity, completion: { result in
                switch result {
                case .success(let publishedActivity):
                    publishedActivity.publishState = .published
                    RLMActivity.createOrUpdateAll(with: [publishedActivity], update: true)
                case .failure(let error):
                    DDLogError("\(error)")
                }
            })
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
                                 message: NSLocalizedString("notification_injury_sent_message", comment: ""))
    }

    func publishInjuries(injuries: [RLMInjury]) {
        NotificationsAPIService.publishInjuries(data: injuries, completion: { result in
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
                                 message: NSLocalizedString("notification_reminder_sent_message", comment: ""))
    }

    func publishReminders(reminders: [RLMReminder]) {

        NotificationsAPIService.publishReminders(data: reminders, completion: { result in
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
