//
//  SlideInPresentationManager.swift
//  Avecare
//
//  Created by stephen on 2020-05-14.
//  Copyright © 2020 Spiria Inc. All rights reserved.
//

import UIKit

enum PresentationDirection {
    case left
    case top
    case right
    case bottom
}

class SlideInPresentationManager: NSObject {
    var direction: PresentationDirection = .left
    var sizeOfPresentingViewController: CGSize = .zero
}

extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(presentedViewController: presented,
                                                                   presenting: presenting,
                                                                   direction: direction,
                                                                   sizeOfPresentingViewController: sizeOfPresentingViewController)
        return presentationController
    }
}
