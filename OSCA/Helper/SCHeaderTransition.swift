/*
Created by Michael on 14.11.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

/**
 *
 * Data Source protocol for the  header transitions
 *
 */
protocol SCHeaderTransitionDataSource : NSObjectProtocol
{
    // reference to content view
    func transitionContentView() -> UIScrollView
    // reference to the header view
    func transitionHeaderView() -> UIView
    
    // sets the initial height of the header view
    func heightForTransitionHeaderView() -> CGFloat

    // defines the threshold of the full transparentt navbar
    func fullTransparentNavbarWhenDistanceGreaterThan() -> CGFloat
    // defines the threshold of the full white navbar
    func fullWhiteNavbarWhenDistanceLessThan() -> CGFloat
    // defines the threshold of the full transparentt nav title
    func fullTransparentNavTitleWhenDistanceGreaterThan() -> CGFloat
    // defines the threshold of the full white nav title
    func fullDarkNavTitleWhenDistanceLessThan() -> CGFloat
}


let transpNavBar : CGFloat = 50.0
let whiteNavBar : CGFloat = 0.0
let transpNavTitle : CGFloat = -15.0
let darkNavTitle : CGFloat = -30.0

/**
 * This class needs a datasource to perfom all needed header/navigation bar
 * transitions
 */
class SCHeaderTransition : NSObject, UIScrollViewDelegate {

    private var contentScrollView = UIScrollView()
    private var headerView = UIView()
    private var headerHeight : CGFloat = 0.0
    private var headerLayer = CAShapeLayer()

    private var transpNavBar : CGFloat = 0.0
    private var whiteNavBar : CGFloat = 0.0
    private var transpNavTitle : CGFloat = 0.0
    private var darkNavTitle : CGFloat = 0.0

    weak var viewController : UIViewController!
    weak private var dataSource : SCHeaderTransitionDataSource?

    var pushNextViewControllerWithoutNavShadow = false

    var swipeToPopStarted = false
    
    /**
     *
     * Convenience initializer
     *
     * @param viewController the viewcontroller that includes the content and headerview. the
     *          controller needs to implement the SCHeaderTransitionDataSource protocol
     *
     */
    convenience init(with viewController: UIViewController & SCHeaderTransitionDataSource) {
        self.init()
        self.viewController = viewController
        self.dataSource = viewController
        self.prepareContentViewAndNavigationbar()
    }
    
    /**
     *
     * Private instance method setup and prepare the header, content and navigation bar
     *
     */
    private func prepareContentViewAndNavigationbar(){
        self.contentScrollView = self.dataSource?.transitionContentView() ?? UIScrollView()
        self.headerView = self.dataSource?.transitionHeaderView() ?? UIView()
        self.headerHeight = self.dataSource?.heightForTransitionHeaderView() ?? 0.0
        
        self.transpNavBar = self.dataSource?.fullTransparentNavbarWhenDistanceGreaterThan() ?? 0.0
        self.whiteNavBar = self.dataSource?.fullWhiteNavbarWhenDistanceLessThan() ?? 0.0
        self.transpNavTitle = self.dataSource?.fullTransparentNavTitleWhenDistanceGreaterThan() ?? 0.0
        self.darkNavTitle = self.dataSource?.fullDarkNavTitleWhenDistanceLessThan() ?? 0.0

        //self.contentScrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        self.contentScrollView.delegate = self
        
        // configure HeaderView and Height
        self.headerLayer = CAShapeLayer()
        self.headerLayer.fillColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!.cgColor
        self.headerView.layer.mask = headerLayer
        
        let newheight = self.headerHeight
        self.contentScrollView.contentInset = UIEdgeInsets(top: newheight, left: 0, bottom: 0, right: 0)
        self.contentScrollView.contentOffset = CGPoint(x: 0, y: -newheight)
        
        layoutHeaderView()
        
        // Navigation Controller Setup
        if self.viewController.navigationController?.navigationBar.isTranslucent ?? true {
            self.viewController.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        }
        self.viewController.navigationController?.navigationBar.shadowImage = UIImage()
        self.viewController.navigationController?.navigationBar.tintColor = UIColor(named: "CLR_NAVBAR_TRANSPARENT_ITEMS")!
        self.viewController.navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "CLR_NAVBAR_TRANSPARENT_ITEMS")!
//        self.viewController.navigationController?.delegate = self
        self.viewController.navigationController?.delegate = self
        self.viewController.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.tintNavigationBar()
    }

    /**
     *
     * This instance method layouts the header view regarding the current position
     * of the content scroll view
     *
     */
    func layoutHeaderView() {
        let newheight = self.headerHeight
        var getheaderframe = CGRect(x: 0, y: -newheight, width: self.contentScrollView.bounds.width, height: self.headerHeight)
        if self.contentScrollView.contentOffset.y < newheight
        {
            getheaderframe.origin.y = self.contentScrollView.contentOffset.y
            getheaderframe.size.height = -self.contentScrollView.contentOffset.y
        }
        self.headerView.frame = getheaderframe
        let cutdirection = UIBezierPath()
        cutdirection.move(to: CGPoint(x: 0, y: 0))
        cutdirection.addLine(to: CGPoint(x: getheaderframe.width, y: 0))
        cutdirection.addLine(to: CGPoint(x: getheaderframe.width, y: getheaderframe.height))
        cutdirection.addLine(to: CGPoint(x: 0, y: getheaderframe.height))
        self.headerLayer.path = cutdirection.cgPath
    }
    

    /**
     *
     * This method tints the navigation bar regarding to the distance
     * of the navigation bar and the top label on the header view.
     * on a short distance the navigation bar is opaque and white.
     * on a long distance the bar will be transparent
     *
     */
    func tintNavigationBar(){
        let currentDistanceToNavbar  = self.calculateDistanceToNavbar()
        
        if (currentDistanceToNavbar < whiteNavBar) {
            self.switchNavigationBarShadow(opacity: true)
        }
        
        if (currentDistanceToNavbar <= transpNavBar) {
            self.viewController.shouldNavBarTransparent = false
            
        } else {
            self.viewController.shouldNavBarTransparent = true
        }
        self.viewController.refreshNavigationBarStyle()
    }
    
    /**
     *
     * This method calculates how far the top label on the header view is away from the
     * navigation bar
     *
     */
    private func calculateDistanceToNavbar() -> CGFloat{
        var navBarHeight : CGFloat = 0.0
        let headerHeight : CGFloat = self.headerView.frame.size.height
        
        if let navigationController = self.viewController.navigationController {
            navBarHeight = navigationController.navigationBar.frame.size.height + navigationController.navigationBar.frame.origin.y
        }
        
        var headerViewElementMinY : CGFloat = 99999.0
        
        // Get the top Label as the beginning Point for the transitions
        for subView in self.headerView.subviews {
            if subView.isKind(of: UILabel.self) {
                if headerViewElementMinY > subView.frame.origin.y {
                    headerViewElementMinY = subView.frame.origin.y
                }
            }
        }
        
        var currentDistanceToNavbar = headerViewElementMinY - navBarHeight
        if (self.contentScrollView.contentOffset.y  > 0.0) {
            currentDistanceToNavbar = -(abs(headerHeight)) - (navBarHeight * 2)
        }
        //print ("calculate:  currentDistanceToNavbar: \(currentDistanceToNavbar)")
        return currentDistanceToNavbar
    }
    
    /**
     *
     * We need to set the transitions when the content is scrolling
     *
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.layoutHeaderView()
        self.tintNavigationBar()
    }
    
    
    /**
     *
     * This function will set the Navigation Bar Shadow to visible or invisible
     *
     */
    func switchNavigationBarShadow(opacity:Bool){
        if #available(iOS 13.0, *) {
        } else {
            if (opacity && self.viewController.navigationController?.navigationBar.shadowImage != nil) {
                self.viewController.navigationController?.navigationBar.shadowImage = nil
            } else if (!opacity && self.viewController.navigationController?.navigationBar.shadowImage == nil) {
                self.viewController.navigationController?.navigationBar.shadowImage = UIImage()
            }
        }
    }
    
    func refreshNavBarShadowOnPushPop () {
        if #available(iOS 13.0, *) {
        } else {
            if let viewControllers = self.viewController.navigationController?.viewControllers {
                if viewControllers.count > 0 {
                    self.switchNavigationBarShadow(opacity: !viewControllers.last!.shouldHideNavBarShadowOnPushPop)
                } else {
                    self.switchNavigationBarShadow(opacity: true)
                }
            }
        }
    }
}


extension SCHeaderTransition : UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        swipeToPopStarted = true
        self.viewController.navigationController?.popViewController(animated: true)
        return false
    }

}

extension SCHeaderTransition: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        self.viewController.shouldNavBarTransparent = false
        self.viewController.refreshNavigationBarStyle()
        
        if let viewControllers = self.viewController.navigationController?.viewControllers {
            if viewControllers.count > 0 {
                self.switchNavigationBarShadow(opacity: !viewControllers.last!.shouldHideNavBarShadowOnPushPop)
            } else {
                self.switchNavigationBarShadow(opacity: true)
            }
        }
        
        if self.viewController.navigationController?.viewControllers.count == 1 {
            self.tintNavigationBar()
        }

    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let viewControllers = self.viewController.navigationController?.viewControllers {
            self.switchNavigationBarShadow(opacity: !viewControllers.last!.shouldHideNavBarShadowOnPushPop)
        }
        
        if self.viewController.navigationController?.viewControllers.count == 1 {
            self.tintNavigationBar()
        }

    }
}

//extension SCHeaderTransition : UINavigationBarDelegate {
//    /*
//     * When we push a new controller to the navigation controller, the we
//     * should set the bar to a white layout
//     */
//    public func navigationBar(_ navigationBar: UINavigationBar, didPush item: UINavigationItem) {
//
//        if let viewControllers = self.viewController.navigationController?.viewControllers {
//            self.switchNavigationBarShadow(opacity: !viewControllers.last!.shouldHideNavBarShadowOnPushPop)
//        }
//
//     }
//    
//    public func navigationBar(_ navigationBar: UINavigationBar, didPop item: UINavigationItem){
//
//        if self.viewController.navigationController?.viewControllers.count == 1 {
//            self.tintNavigationBar()
//        }
//   }
//    
//    public func navigationBar(_ navigationBar: UINavigationBar, shouldPush item: UINavigationItem) -> Bool {
//        self.viewController.shouldNavBarTransparent = false
//        self.viewController.refreshNavigationBarStyle()
//        
//        if let viewControllers = self.viewController.navigationController?.viewControllers {
//            if viewControllers.count > 0 {
//                self.switchNavigationBarShadow(opacity: !viewControllers.last!.shouldHideNavBarShadowOnPushPop)
//            } else {
//                self.switchNavigationBarShadow(opacity: true)
//            }
//        }
//
//        return true
//    }
//    
//    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
//        if let viewControllers = self.viewController.navigationController?.viewControllers {
//            let controllerCount = viewControllers.count
//            if controllerCount > 1 {
//                self.switchNavigationBarShadow(opacity: !viewControllers[(controllerCount-2)].shouldHideNavBarShadowOnPushPop)
//            } else {
//                self.switchNavigationBarShadow(opacity: true)
//            }
//        }
//
//        let topViewController = self.viewController.navigationController?.topViewController
//        let manualPop = topViewController!.navigationItem == item
//        
//        if manualPop && !self.swipeToPopStarted {
//            self.viewController.navigationController?.popViewController(animated: true)
//        }
//        
//        if self.viewController.navigationController?.viewControllers.count == 1 {
//            self.tintNavigationBar()
//        }
//        
//        swipeToPopStarted = false
//        return true
//    }
//    
//}
