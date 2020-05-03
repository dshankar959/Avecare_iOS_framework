import CocoaLumberjack

class UINVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogInfo("\(self)")

/*
        // Transparent Navigation bar  (translucent)   [helps debugging views behind it]
        navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationBar.shadowImage = UIImage()  // separator
        navigationBar.backgroundColor = UIColor.magenta.withAlphaComponent(0.2)
        navigationBar.isTranslucent = true
*/

        navigationBar.isTranslucent = false

    }

/*
    override open func updateViewConstraints() {
        super.updateViewConstraints()
        DDLogInfo("")
    }


    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        DDLogInfo("")
        view.setNeedsUpdateConstraints()
    }
*/

    override open var shouldAutorotate: Bool {
        if let topVC = self.topViewController {
//            DDLogVerbose("topVC \(topVC) .shouldAutorotate = \(topVC.shouldAutorotate)")
            return topVC.shouldAutorotate
        }

//        DDLogVerbose(".shouldAutorotate = true")
        return true
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        DDLogInfo("")
        if let topVC = self.topViewController {
//            DDLogInfo("topVC = \(topVC)")
//            DDLogInfo("topVC.supportedInterfaceOrientations = \(topVC.supportedInterfaceOrientations)")
            return topVC.supportedInterfaceOrientations
        }

        return UIInterfaceOrientationMask.all
    }

/*
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DDLogInfo("")
//        view.setNeedsUpdateConstraints()

//        return (self.topViewController?.supportedInterfaceOrientations)!

        self.topViewController?.viewWillTransition(to: size, with: coordinator)

    }
*/

    deinit {
        DDLogWarn("\(self)")
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        DDLogError("")
    }

}

// https://stackoverflow.com/questions/12904410/completion-block-for-popviewcontroller
extension UINavigationController {
    func pushToViewController(_ viewController: UIViewController, animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }

    func popViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: true)
        CATransaction.commit()
    }

    func popToViewController(_ viewController: UIViewController, animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToViewController(viewController, animated: animated)
        CATransaction.commit()
    }

    func popToRootViewController(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popToRootViewController(animated: animated)
        CATransaction.commit()
    }
}
