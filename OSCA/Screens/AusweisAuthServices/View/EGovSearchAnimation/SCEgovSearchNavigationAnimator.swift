/*
Created by Bharat Jagtap on 18/10/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import UIKit

// MARK: - SCEgovSearchNavigationTransitionOriginator

protocol SCEgovSearchNavigationTransitionOriginator {
    var fromAnimatedSubviews: [UIView] { get }
    var viewsToBeHiddenDuringTransition: [UIView]? { get }
}

// MARK: - SCEgovSearchNavigationTransitionDestination

protocol SCEgovSearchNavigationTransitionDestination {
    var toAnimatedSubviews: [UIView] { get }
    var viewsToBeHiddenDuringTransition: [UIView]? { get }
}


// MARK: - SCEgovSearchNavigationAnimator

class SCEgovSearchNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning, UINavigationControllerDelegate {
   
    enum TransitionType {
        case present
        case dismiss
    }

    let type: TransitionType

    init(type: TransitionType) {
        self.type = type
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from) as? SCEgovSearchNavigationTransitionOriginator  & UIViewController,
              let toVC   = transitionContext.viewController(forKey: .to)   as? SCEgovSearchNavigationTransitionDestination & UIViewController else {
            
            return
        }
        
        let container = transitionContext.containerView

        // add the "to" view to the hierarchy

        toVC.view.frame = fromVC.view.frame
        if type == .present {
            container.addSubview(toVC.view)
        } else {
            container.insertSubview(toVC.view, belowSubview: fromVC.view)
        }
        toVC.view.layoutIfNeeded()

        // create snapshots of label being animated

        let fromSnapshots = fromVC.fromAnimatedSubviews.map { subview -> UIView in
            // create snapshot

            let snapshot = subview.snapshotView(afterScreenUpdates: false)!

            // we're putting it in container, so convert original frame into container's coordinate space

            snapshot.frame = container.convert(subview.frame, from: subview.superview)

            return snapshot
        }

        let toSnapshots = toVC.toAnimatedSubviews.map { subview -> UIView in
            // create snapshot

            let snapshot = subview.snapshotView(afterScreenUpdates: true)!// UIImageView(image: subview.snapshot())

            // we're putting it in container, so convert original frame into container's coordinate space

            snapshot.frame = container.convert(subview.frame, from: subview.superview)

            return snapshot
        }

        // save the "to" and "from" frames

        let frames = zip(fromSnapshots, toSnapshots).map { ($0.frame, $1.frame) }

        // move the "to" snapshots to where where the "from" views were, but hide them for now

        zip(toSnapshots, frames).forEach { snapshot, frame in
            snapshot.frame = frame.0
            snapshot.alpha = 0
            container.addSubview(snapshot)
        }

        // add "from" snapshots, too, but hide the subviews that we just snapshotted
        // associated labels so we only see animated snapshots; we'll unhide these
        // original views when the animation is done.

        fromSnapshots.forEach { container.addSubview($0) }
        fromVC.fromAnimatedSubviews.forEach { $0.alpha = 0 }
        toVC.toAnimatedSubviews.forEach { $0.alpha = 0 }

        if type == .present {
            //toVC.view.transform = .init(translationX: toVC.view.frame.width, y: 0)
            toVC.view.alpha = 1.0
            fromVC.view.alpha = 0.5
        } else {
            toVC.view.alpha = 1.0
            fromVC.view.alpha = 1.0
        }

        if type == .present {
            
            toVC.viewsToBeHiddenDuringTransition?.forEach({ view in
                view.isHidden = true
            })
            
        } else {
            
            fromVC.viewsToBeHiddenDuringTransition?.forEach({ view in
                view.isHidden = true
            })
        }
        
        // do the animation

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            // animate the snapshots of the label

            zip(toSnapshots, frames).forEach { snapshot, frame in
                snapshot.frame = frame.1
                snapshot.alpha = 1
            }

            zip(fromSnapshots, frames).forEach { snapshot, frame in
                snapshot.frame = frame.1
                snapshot.alpha = 1
            }

            // I'm now animating the "to" view into place, but you'd do whatever you want here

            if self.type == .present {
                fromVC.view.alpha = 0.0
                toVC.view.alpha = 1.0
            } else {
                fromVC.view.alpha = 0.0
                toVC.view.alpha = 1.0
            }
        }, completion: { _ in
            // get rid of snapshots and re-show the original labels

            fromSnapshots.forEach { $0.removeFromSuperview() }
            toSnapshots.forEach   { $0.removeFromSuperview() }
            fromVC.fromAnimatedSubviews.forEach { $0.alpha = 1 }
            toVC.toAnimatedSubviews.forEach { $0.alpha = 1 }

            // clean up "to" and "from" views as necessary, in my case, just restore "from" view's alpha

            fromVC.view.alpha = 1
            fromVC.view.transform = .identity
            toVC.view.alpha = 1
            toVC.view.transform = .identity

            // complete the transition
            
            toVC.viewsToBeHiddenDuringTransition?.forEach({ view in
                view.isHidden = false
            })
            
            fromVC.viewsToBeHiddenDuringTransition?.forEach({ view in
                view.isHidden = false
            })

            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}


// MARK: - SCEgovSearchNavigationTransitionCoordinator

class SCEgovSearchNavigationTransitionCoordinator: NSObject, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .push:
            return SCEgovSearchNavigationAnimator(type: .present)
        case .pop:
            return SCEgovSearchNavigationAnimator(type: .dismiss)
        default:
            return nil
        }
                
    }
    
}
