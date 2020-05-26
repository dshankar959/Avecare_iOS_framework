import UIKit



class SlideInPresentationController: UIPresentationController {
    private var dimmingView: UIView!
    private var direction: PresentationDirection
    private var sizeOfPresentingViewController: CGSize! // default size when its value is .zero

    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         direction: PresentationDirection,
         sizeOfPresentingViewController: CGSize = .zero) {
        self.direction = direction
        self.sizeOfPresentingViewController = sizeOfPresentingViewController

        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)

        setupDimmingView()
    }

    override func presentationTransitionWillBegin() {
        guard let dimmingView = dimmingView else {
            return
        }

        containerView?.insertSubview(dimmingView, at: 0)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            dimmingView.alpha = 1.0
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize
    ) -> CGSize {
        switch direction {
        case .left, .right:
            if sizeOfPresentingViewController == .zero {
                return CGSize(width: parentSize.width * (2.0 / 3.0), height: parentSize.height)
            } else {
                let width = min(sizeOfPresentingViewController.width, parentSize.width * (2.0 / 3.0))
                return CGSize(width: width, height: parentSize.height)
            }
        case .top, .bottom:
            if sizeOfPresentingViewController == .zero {
                return CGSize(width: parentSize.width, height: parentSize.height * (2.0 / 3.0))
            } else {
                // set max height (2/3 of parent size)
                let height = min(sizeOfPresentingViewController.height, parentSize.height * (2.0 / 3.0))
                return CGSize(width: parentSize.width, height: height)
            }
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentingViewController,
                          withParentContainerSize: containerView!.bounds.size)

        switch direction {
        case .right:
            if sizeOfPresentingViewController == .zero {
                frame.origin.x = containerView!.frame.width * (1.0 / 3.0)
            } else {
                let width = min(sizeOfPresentingViewController.width, containerView!.frame.width * (2.0 / 3.0))
                frame.origin.x = containerView!.frame.width - width
            }
        case .bottom:
            if sizeOfPresentingViewController == .zero {
                frame.origin.y = containerView!.frame.height * (1.0 / 3.0)
            } else {
                let height = min(sizeOfPresentingViewController.height, containerView!.frame.height * (2.0 / 3.0))
                frame.origin.y = containerView!.frame.height - height
            }
        default:
            frame.origin = .zero
        }

        return frame
    }
}

private extension SlideInPresentationController {
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
    }

    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
}
