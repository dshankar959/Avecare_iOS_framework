import UIKit
import IHProgressHUD



protocol IndicatorProtocol: class {
    func showActivityIndicator(withStatus: String, containerView: UIView, maskType: IHProgressHUDMaskType, completion:@escaping () -> Void)
    func showActivityIndicator(withStatus: String, progress: Double, containerView: UIView, maskType: IHProgressHUDMaskType, completion:@escaping () -> Void)
    func showSuccessIndicator(withStatus: String, containerView: UIView)
    func showErrorIndicator(withStatus: String, containerView: UIView)
    func hideActivityIndicator()
    func dismissAllIndicatorActivity()
    func showErrorAlert(_ error: AppError?, inVC: UIViewController?)
}


extension IndicatorProtocol {

    func showErrorAlert(_ error: AppError?,
                        inVC: UIViewController? = nil) {

        self.hideActivityIndicator()

        if let err = error {
            self.popupAlert(inVC: inVC,
                            title: err.title,
                            message: err.localizedDescription,
                            actionTitles: [NSLocalizedString("alert_ok", comment: "")],
                            actionStyles: [.default],
                            actions: [nil])
        }

    }


    func showActivityIndicator(withStatus: String = "",
                               containerView: UIView = appDelegate.window!,
                               maskType: IHProgressHUDMaskType = .none,
                               completion:@escaping () -> Void = {}) {

        IHProgressHUD.set(defaultMaskType: maskType)
        IHProgressHUD.set(containerView: containerView)
        IHProgressHUD.set(minimumDismiss: 1.0)
        IHProgressHUD.set(maximumDismissTimeInterval: 2.0)
        IHProgressHUD.show(withStatus: withStatus)

        OperationQueue.main.addOperation({
            completion()
        })

    }


    func showActivityIndicator(withStatus: String = "",
                               progress: Double,
                               containerView: UIView = appDelegate.window!,
                               maskType: IHProgressHUDMaskType = .none,
                               completion:@escaping () -> Void = {}) {

        IHProgressHUD.set(defaultMaskType: maskType)
        IHProgressHUD.set(containerView: containerView)
        IHProgressHUD.set(minimumDismiss: 1.0)
        IHProgressHUD.set(maximumDismissTimeInterval: 2.0)
        IHProgressHUD.show(progress: CGFloat(progress), status: withStatus)

        OperationQueue.main.addOperation({
            completion()
        })

/*
        // Noted example from git ReadMe:
        IHProgressHUD.show()
        DispatchQueue.global(qos: .default).async(execute: {
            // time-consuming task
            IHProgressHUD.dismiss()
        })
*/
    }


    func showSuccessIndicator(withStatus: String = "", containerView: UIView = appDelegate.window!) {

        IHProgressHUD.set(defaultMaskType: .none)
        IHProgressHUD.set(containerView: containerView)
        IHProgressHUD.set(minimumDismiss: 1.0)
        IHProgressHUD.set(maximumDismissTimeInterval: 2.0)
        IHProgressHUD.showSuccesswithStatus(withStatus)
    }


    func showErrorIndicator(withStatus: String = "", containerView: UIView = appDelegate.window!) {

        IHProgressHUD.set(defaultMaskType: .none)
        IHProgressHUD.set(containerView: containerView)
        IHProgressHUD.set(minimumDismiss: 1.0)
        IHProgressHUD.set(maximumDismissTimeInterval: 2.0)
        IHProgressHUD.showError(withStatus: withStatus)
    }


    func hideActivityIndicator() {

        IHProgressHUD.set(containerView: appDelegate.window)
        IHProgressHUD.set(defaultMaskType: .none)
        IHProgressHUD.set(minimumDismiss: 1.0)
        IHProgressHUD.set(maximumDismissTimeInterval: 2.0)
        IHProgressHUD.popActivity()
    }


    func dismissAllIndicatorActivity() {
        IHProgressHUD.dismiss()
    }


    func isActivityIndicatorVisible() -> Bool {
        return IHProgressHUD.isVisible()
    }


    // actions and handlers.
    // https://stackoverflow.com/a/42622755/7599
    func popupAlert(inVC: UIViewController? = nil,
                    title: String?,
                    message: String?,
                    actionTitles: [String?],
                    actionStyles: [UIAlertAction.Style],
                    actions: [((UIAlertAction) -> Void)?]) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: actionStyles[index], handler: actions[index])
            alert.addAction(action)
        }

        if let vc = inVC {
            vc.present(alert, animated: true, completion: nil)
        } else {
            let topVC = UIViewController().topMostController()
            topVC?.present(alert, animated: true, completion: nil)
        }


    }

}
