/*
Created by Robert Swoboda - Telekom on 20.05.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Robert Swoboda
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
