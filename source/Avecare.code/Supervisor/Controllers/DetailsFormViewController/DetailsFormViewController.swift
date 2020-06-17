import UIKit
import SnapKit



class DetailsFormViewController: UIViewController {

    @IBOutlet weak var detailsView: DetailsView!
    @IBOutlet weak var navigationHeaderView: DetailsNavigationView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!


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
