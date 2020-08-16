import UIKit
import CocoaLumberjack



extension SubjectListDataProvider: IndicatorProtocol {

    func navigationItems(at indexPath: IndexPath) -> [DetailsNavigationView.Item] {
        let subject = dataSource[indexPath.row]
        let isSubmitted = subject.isFormSubmittedToday

        let publishColor = isSubmitted ? R.color.lightText4() : R.color.main()

        return [
            // Navigation + for selected subject
            .imageButton(options: .init(action: { [weak self] view, options, index in
                let items = RLMLogChooseRow.findAll()

                let picker = SingleValuePickerView(values: items)
                picker.backgroundColor = .white

                guard let toolbar = self?.defaultToolbarView(onDone: {
                    guard let subject = self?.dataSource[indexPath.row],
                          let row = picker.selectedValue?.row?.detached() else {
                        return
                    }

                    row.prepareForReuse()

                    self?.delegate?.customResponder?.resignFirstResponder()

                    let logForm = subject.todayForm
                    RLMLogForm.writeTransaction {
                        logForm.rows.append(row)
                    }

                    self?.delegate?.didUpdateModel(at: indexPath)

                }, onCancel: {
                    self?.delegate?.customResponder?.resignFirstResponder()
                }) else {
                    return
                }

                self?.delegate?.customResponder?.resignFirstResponder()
                self?.delegate?.customResponder?.becomeFirstResponder(inputView: picker, accessoryView: toolbar)

            }, isEnabled: !isSubmitted, image: R.image.plusIcon())),
            .offset(value: 10),
            // Navigation Publish for selected subject
            .button(options: .init(action: { [weak self] view, options, index in
                self?.publishDailyForm(at: indexPath)
            }, isEnabled: !isSubmitted,
               text: NSLocalizedString("logs_publish_button_title", comment: ""),
               textColor: R.color.mainInversion(),
               tintColor: publishColor, cornerRadius: 4))
        ]

    }


    func publishDailyForm(at indexPath: IndexPath) {
        let form = dataSource[indexPath.row].todayForm

        RLMLogForm.writeTransaction {
            form.clientLastUpdated = Date()
            form.publishState = .publishing
        }

        self.delegate?.didUpdateModel(at: indexPath)

        syncEngine.syncAll { error in
            if let error = error {
                DDLogError("\(error)")
                self.showErrorAlert(error)
            }
        }

    }

}