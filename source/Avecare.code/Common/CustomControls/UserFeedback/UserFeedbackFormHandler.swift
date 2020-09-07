import UIKit
import CocoaLumberjack



extension UserFeedbackVC {  // UITableViewDataSource

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let feedbackSection: UserFeedbackSection = self.viewModel.allSections[section]

        if feedbackSection == UserFeedbackSection.feedback {
            return "Talk to us.  💬"
        }

        return ""
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.sectionCount
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.count(for: section)
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.viewModel.row(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)

        if let textCell = cell as? MultilineTextTableViewCell {
            textCell.backgroundColor = .white
            textCell.content = viewModel.userComments
            textCell.placeholder = "Comments"
            textCell.delegate = self

        } else if let toggleCell = cell as? ToggleTableViewCell {
            toggleCell.textLabel?.text = "Include log files"
            toggleCell.on = viewModel.includeLogfiles
            toggleCell.delegate = self

        } else if let buttonCell = cell as? ButtonTableViewCell {
            buttonCell.delegate = self

        } else {
            return UITableViewCell()
        }

        return cell
    }


    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: UserFeedbackRow.send.rowHeight*2))

        let appInfoView = AppInfoView(frame: CGRect.zero)

        footerView.setSubviewForAutoLayout(appInfoView)

        appInfoView.snp.remakeConstraints { (make) -> Void in
            make.width.equalToSuperview()
            make.height.equalTo(footerView.frame.size.height)
            make.centerX.equalToSuperview()
        }

        return footerView
    }

}


extension UserFeedbackVC {  // UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = self.viewModel.row(for: indexPath)

        return row.rowHeight
    }

}


extension UserFeedbackVC: MultilineTextTableViewCellDelegate {

    func multilineTextTableViewCellDidChange(_ cell: MultilineTextTableViewCell) {
        if let content = cell.content {
            // Update the text:
            viewModel.userComments = content

            // Begin and end tableview updates to adjust the
            // cell height as the text length changes:
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }


    func multilineTextTableViewCell(_ cell: MultilineTextTableViewCell,
                                    shouldChangeTextIn range: NSRange,
                                    replacementText text: String) -> Bool {
//        if text == "\n" {
//            cell.contentTextView?.resignFirstResponder()
//            return false
//        }

        return true
    }


    func multilineTextTableViewCellDidEndEditing(_ cell: MultilineTextTableViewCell) {
    }

}


extension UserFeedbackVC: ToggleTableViewCellDelegate, ButtonTableViewCellDelegate {

    func didToggleSwitch(on: Bool) {
        DDLogInfo("on = \(on)")

        viewModel.includeLogfiles = on
        view.endEditing(true)   // dimiss keyboard
    }

    func didPressButton() {
        DDLogInfo("")
        view.endEditing(true)   // dimiss keyboard

        DDLogVerbose("comments = \(viewModel.userComments)")
        DDLogVerbose("includeLogfiles = \(viewModel.includeLogfiles)")

        showSuccessIndicator(withStatus: "Success! 👍") // testing

        showActivityIndicator(withStatus: "Sending feedback package.")

        UserAPIService.submitUserFeedback(for: appSession,
                                          comments: viewModel.userComments,
                                          withLogfiles: viewModel.includeLogfiles) { [weak self] error in
            if let error = error {
                DDLogError("submitUserFeedback error = \(error)")
                self?.showErrorAlert(error)
            } else {
                self?.showSuccessIndicator(withStatus: "Success! 👍")
            }
        }

    }

}
