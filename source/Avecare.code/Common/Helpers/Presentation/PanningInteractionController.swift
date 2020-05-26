//
//  PanningInteractionController.swift
//  Avecare
//
//  Created by stephen on 2020-05-25.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import UIKit

class PanningInteractionController: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false
    private var shouldCompleteTransition = false

    private weak var viewController: UIViewController!
    private let direction: PresentationDirection

    init(viewController: UIViewController, direction: PresentationDirection) {
        self.viewController = viewController
        self.direction = direction

        super.init()

        pregareGesture(in: viewController.view)
    }

    private func pregareGesture(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self,
                                             action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(gesture)
    }

    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress: CGFloat
        switch direction {
        case .left:
            progress = (-translation.x / viewController.view.frame.width)
        case .right:
            progress = (translation.x / viewController.view.frame.width)
        case .top:
            progress = (-translation.y / viewController.view.frame.height)
        case .bottom:
            progress = (translation.y / viewController.view.frame.height)
        }
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))

        switch gestureRecognizer.state {
        case .began:
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
        case .cancelled:
            interactionInProgress = false
            cancel()
        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}
