//
//  SCLocationSegue.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 20.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCLocationSegue: UIStoryboardSegue {

    static let duration = 0.25
    
    override func perform() {
        destination.transitioningDelegate = self
        destination.modalPresentationStyle = .overCurrentContext
        
        source.present(destination, animated: true, completion: nil)
    }
}

extension SCLocationSegue: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Presenter()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Dismisser()
    }
}

private class Presenter: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        containerView.addSubview(toView)
        
        // Respect `toViewController.preferredContentSize.height` if non-zero.
        if toViewController.preferredContentSize.height > 0 {
            toView.heightAnchor.constraint(equalToConstant: toViewController.preferredContentSize.height).isActive = true
        }
        
        // Perform the animation
        containerView.layoutIfNeeded()
        let originalOriginX = toView.frame.origin.x
        toView.frame.origin.x = -toView.frame.width
        
        UIView.animate(withDuration: SCLocationSegue.duration, animations: {
            toView.frame.origin.x = originalOriginX
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
}

private class Dismisser: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return SCLocationSegue.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerViewController = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        
        containerView.alpha = 1.0
        
        UIView.animate(withDuration: SCLocationSegue.duration, animations: {
            fromView.frame.origin.x = -containerView.frame.width
            containerViewController.shouldNavBarTransparent = true
            containerViewController.refreshNavigationBarStyle()
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
}
