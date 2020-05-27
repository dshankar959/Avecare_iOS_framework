import UIKit



enum PresentationDirection {
    case left
    case top
    case right
    case bottom
}

class SlideInPresentationManager: NSObject {
    var direction: PresentationDirection = .bottom
    var sizeOfPresentingViewController: CGSize = .zero
}


extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {

        return SlideInPresentationController(presentedViewController: presented,
                                             presenting: presenting,
                                             direction: direction,
                                             sizeOfPresentingViewController: sizeOfPresentingViewController)
    }


    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return SlideInPresentationAnimator(direction: direction, isPresentation: true)
    }


    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        #if SUPERVISOR
        // Put presented view controllers for SUPERVISOR type apps here.

        #elseif GUARDIAN
        // Put presented view controllers for GUARDIAN type apps here
        if let subjectListVC = dismissed as? SubjectListViewController {
            return SlideInPresentationAnimator(direction: direction,
                                               isPresentation: false,
                                               interactionController: subjectListVC.panningInterationController)
        } else if let educatorDetailsVC = dismissed as? EducatorDetailsViewController {
            return SlideInPresentationAnimator(direction: direction,
                                               isPresentation: false,
                                               interactionController: educatorDetailsVC.panningInterationController)
        }
        #endif

        return SlideInPresentationAnimator(direction: direction, isPresentation: false)
    }


    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        guard let animator = animator as? SlideInPresentationAnimator,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress else {
                return nil
        }

        return interactionController
    }

}
