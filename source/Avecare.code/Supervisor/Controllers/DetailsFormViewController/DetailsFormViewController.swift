import UIKit
import SnapKit
import CocoaLumberjack



class DetailsFormViewController: UIViewController {

    @IBOutlet weak var detailsView: DetailsView!
    @IBOutlet weak var navigationHeaderView: DetailsNavigationView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var synStatusButton: UIButton!
    @IBAction func syncButtonPressed(_ sender: Any) {
        // Silent Sync call
        syncEngine.syncAll { error in
            if let error = error {
                DDLogError("\(error)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.syncing), name: .syncStateChanged, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.syncDidComplete), name: .didCompleteSync, object: nil)
    }

    @objc func syncDidComplete() {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = R.color.blueIcon()
        var stringToShow = NSLocalizedString("all_synced", comment: "")
        if !isDataConnection {
            stringToShow = NSLocalizedString("all_synced_offline", comment: "")
        }
        let title = NSAttributedString(string: stringToShow, attributes: attributes)
        synStatusButton.setAttributedTitle(title, for: .normal)
    }

    @objc func syncing() {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.blue
        let title = NSAttributedString(string: NSLocalizedString("syncing_title", comment: ""), attributes: attributes)
        synStatusButton.setAttributedTitle(title, for: .normal)
    }

    func updateSyncButton() {
        if syncEngine.isSyncUpRequired() {
            if syncEngine.isSyncing {
                syncing()
            } else {
                var attributes = [NSAttributedString.Key: AnyObject]()
                attributes[.foregroundColor] = R.color.redIcon()
                var stringToShow = NSLocalizedString("waiting_to_sync", comment: "")
                if !isDataConnection {
                    stringToShow = NSLocalizedString("waiting_to_sync_offline", comment: "")
                }
                let title = NSAttributedString(string: stringToShow, attributes: attributes)
                synStatusButton.setAttributedTitle(title, for: .normal)
            }
        } else {
                self.syncDidComplete()
            }
    }


    @objc func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo,
              let endFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
              let animationCurve = (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
            return
        }

        let keyboardEndFrame = view.convert(endFrame, from: nil)
        let contentFrame = view.convert(view.bounds, to: nil)

        let delta = contentFrame.size.height + contentFrame.origin.y - keyboardEndFrame.origin.y

        bottomConstraint.constant = delta

        let options = UIView.AnimationOptions(rawValue: animationCurve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        })
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        guard let info = notification.userInfo,
              let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
              let animationCurve = (info[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue else {
            return
        }

        bottomConstraint.constant = 0

        let options = UIView.AnimationOptions(rawValue: animationCurve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func endEditingGesture(_ recognizer: UITapGestureRecognizer) {
        detailsView.endEditing(false)
    }

}
