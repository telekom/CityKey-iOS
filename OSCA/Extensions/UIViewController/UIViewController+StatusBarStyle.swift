/*
Created by Michael on 05.11.18.
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
 * Extension for the UIController to layout and style the NavigationBar
 *
 */
extension UIViewController {
    
    private static var _shouldHideNavBarShadowOnPushPop = [ObjectIdentifier: Bool]()
    private static var _shouldNavBarTransparent = [ObjectIdentifier: Bool]()

    var shouldHideNavBarShadowOnPushPop:Bool {
        get {
            let tmpAddress = ObjectIdentifier(self)
            return UIViewController._shouldHideNavBarShadowOnPushPop[tmpAddress] ?? false
        }
        set(newValue) {
            let tmpAddress = ObjectIdentifier(self)
            UIViewController._shouldHideNavBarShadowOnPushPop[tmpAddress] = newValue
        }
    }

    var shouldNavBarTransparent:Bool {
        get {
            let tmpAddress = ObjectIdentifier(self)
            return UIViewController._shouldNavBarTransparent[tmpAddress] ?? false
        }
        set(newValue) {
            let tmpAddress = ObjectIdentifier(self)
            UIViewController._shouldNavBarTransparent[tmpAddress] = newValue
        }
    }
    
    func refreshNavigationBarStyle(){
        if self.shouldNavBarTransparent {
            self.transparentNavigationBarStyle()
        } else {
            self.refreshNavigationBarStyle(opacity: true)
        }
    }
    
    /**
     *
     * Method to set an image instead of a text in the navigation bar
     *
     */
    func addNavBarImage(imageUrl: SCImageURL){

        if let navController = self.navigationController {
            
            // Check if we have already added an imageView to the navigationItem
            if let imageView = navigationItem.titleView?.viewWithTag(GlobalConstants.kNavigationBarTilteImageViewTag) as? UIImageView {
                imageView.load(from: imageUrl)
            } else {
                // Otherwise we will add it
                let imageView = UIImageView()
                imageView.load(from: imageUrl)
                imageView.tag = GlobalConstants.kNavigationBarTilteImageViewTag
                imageView.contentMode = .scaleAspectFit
                
                let safeBottomMargin : CGFloat = 8.0
                let bannerHeight = navController.navigationBar.frame.size.height - safeBottomMargin
                let bannerWidth = navController.navigationBar.frame.size.width
                
                let titleView = UIView(frame: CGRect( x: 0.0, y: 0.0, width: bannerWidth, height: bannerHeight))
                imageView.frame = CGRect(x: 0, y: 0, width: titleView.frame.width, height: titleView.frame.height)
                imageView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
                titleView.addSubview(imageView)
                navigationItem.titleView = titleView
                navigationItem.titleView?.alpha = self.shouldNavBarTransparent ? 0.0 : 1.0
            }
        }
    }

    /**
     *
     * Method to remove ImageView from the navigationBar
     *
     */
    func removeNavBarImage(){
        
        navigationItem.titleView = nil
    }

    
    /**
     *
     * Method to set the Navigation Bar to the default OSCA style
     *
     */
    private func refreshNavigationBarStyle(opacity: Bool){

        let color = UIColor(named: "CLR_NAVBAR_SOLID_BCKGRND")!
        let navigationcolorElement = UIColor(named: "CLR_NAVBAR_SOLID_ITEMS")!
        let navigationcolorTitle = UIColor(named: "CLR_NAVBAR_SOLID_TITLE")!
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            
            if (opacity) {
                navBarAppearance.configureWithOpaqueBackground()
                navigationController?.navigationBar.tintColor = UIColor(named: "CLR_NAVBAR_SOLID_ITEMS")
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "CLR_NAVBAR_SOLID_ITEMS")
                self.navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "CLR_NAVBAR_SOLID_ITEMS")
                self.navigationItem.titleView?.alpha =  1.0
                self.navBarImageTransparency(alpha: 1.0)
 
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor:  UIColor(named: "CLR_NAVBAR_SOLID_TITLE")!]
                navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(named: "CLR_NAVBAR_SOLID_TITLE")!]
                navBarAppearance.backgroundColor = UIColor(named: "CLR_NAVBAR_SOLID_BCKGRND")
            } else {
                navBarAppearance.configureWithTransparentBackground()
                navigationController?.navigationBar.tintColor = UIColor(named: "CLR_NAVBAR_TRANSPARENT_ITEMS")
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "CLR_NAVBAR_TRANSPARENT_ITEMS")
                self.navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "CLR_NAVBAR_TRANSPARENT_ITEMS")
//                self.navigationItem.titleView?.alpha =  0.0
//                self.navBarImageTransparency(alpha: 0.0)

                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.clear]
                navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.clear]
            }


            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.compactAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

//            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.isTranslucent = true

            self.setNeedsStatusBarAppearanceUpdate()

        } else {
            self.navigationController?.navigationBar.isTranslucent = true
            self.switchNavigationBarShadow(opacity: opacity)

            if opacity {
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navigationcolorTitle]
                
                // only do this when the nav is translucent. but in this case there is a
                // problem with the shadow on large titles
                if self.navigationController?.navigationBar.isTranslucent ?? true {
                    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                }
                
                self.navigationController?.navigationBar.tintColor = navigationcolorElement
                self.navigationItem.rightBarButtonItem?.tintColor = navigationcolorElement
                self.navigationItem.leftBarButtonItem?.tintColor = navigationcolorElement
                self.navigationController?.navigationBar.backgroundColor = color
                if let statusBarView = UIApplication.shared.statusBarView {
                    statusBarView.backgroundColor = color
                }
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navigationcolorTitle]
                self.navigationController?.navigationBar.barStyle = .default
                self.navBarImageTransparency(alpha: opacity ? 1.0 : 0.0)
            } else {
                self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                
                let color = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.0)
                self.navigationController?.navigationBar.tintColor = UIColor.white
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
                self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
                self.navigationController?.navigationBar.backgroundColor = color
                if let statusBarView = UIApplication.shared.statusBarView {
                    statusBarView.backgroundColor = .clear
                }
                self.navigationController?.navigationBar.barStyle = .black
                self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:color]
                //self.refreshStatusBar(style: .lightContent)
                self.navBarImageTransparency(alpha: 0.0)
            }

            self.setNeedsStatusBarAppearanceUpdate()
        }

    }
    
    /**
     *
     * Method to set the Navigation Bar to a transparent style
     *
     */
    private func transparentNavigationBarStyle(){
        self.refreshNavigationBarStyle(opacity: false)
     }
    


    // METHOD for setting Navigation Bar Shadow visible or invisible
    func switchNavigationBarShadow(opacity:Bool){
        if #available(iOS 13.0, *) {
        } else {
            if (opacity && self.navigationController?.navigationBar.shadowImage != nil) {
                self.navigationController?.navigationBar.shadowImage = nil
            } else if (!opacity && self.navigationController?.navigationBar.shadowImage == nil) {
                self.navigationController?.navigationBar.shadowImage = UIImage()
            }
        }
    }
    
    /**
     *
     * Method to control the alpha channel of the ImageView in the navigationBar
     *
     */
    private func navBarImageTransparency(alpha: CGFloat) {
        navigationItem.titleView?.alpha = alpha
    }
}


/*extension UIViewController {
    
    func refreshStatusBar(style : UIStatusBarStyle){
       if (SCUtilities.statusBarStyle != style) {
            SCUtilities.statusBarStyle = style
            self.setNeedsStatusBarAppearanceUpdate()
            UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    /**
     *
     * Method to set an image instead of a text in the navigation bar
     *
     */
    func addNavBarImage(imageUrl: SCImageURL){

        if let navController = self.navigationController {
            
            // Check if we have already added an imageView to the navigationItem
            if let imageView = navigationItem.titleView?.viewWithTag(GlobalConstants.kNavigationBarTilteImageViewTag) as? UIImageView {
                imageView.load(from: imageUrl)
            } else {
                // Otherwise we will add it
                let imageView = UIImageView()
                imageView.load(from: imageUrl)
                imageView.tag = GlobalConstants.kNavigationBarTilteImageViewTag
                imageView.contentMode = .scaleAspectFit
                
                let safeBottomMargin : CGFloat = 8.0
                let bannerHeight = navController.navigationBar.frame.size.height - safeBottomMargin
                let bannerWidth = navController.navigationBar.frame.size.width
                
                let titleView = UIView(frame: CGRect( x: 0.0, y: 0.0, width: bannerWidth, height: bannerHeight))
                imageView.frame = CGRect(x: 0, y: 0, width: titleView.frame.width, height: titleView.frame.height)
                imageView.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
                titleView.addSubview(imageView)
                navigationItem.titleView = titleView
                navigationItem.titleView?.alpha = self.navigationController?.navigationBar.shadowImage == nil ? 1.0 : 0.0
            }
        }
    }

    /**
     *
     * Method to remove ImageView from the navigationBar
     *
     */
    func removeNavBarImage(){
        
        navigationItem.titleView = nil
    }

    
    /**
     *
     * Method to set the Navigation Bar to the default OSCA style
     *
     */
    func defaultNavigationBarStyle(navBarAlpha : CGFloat, navBarTitleAlpha : CGFloat){
        
        let color = GlobalConstants.kColor_navigationBarBackColor.withAlphaComponent(navBarAlpha)
        let navigationcolorElement = GlobalConstants.kColor_navigationBarForeColor.withAlphaComponent(navBarAlpha)
        let navigationcolorTitle = GlobalConstants.kColor_navigationBarForeColor.withAlphaComponent(navBarTitleAlpha)
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navigationcolorTitle]
        self.navBarImageTransparency(alpha: navBarTitleAlpha)
        self.switchNavigationBarShadow(opacity: true)
        
        // only do this when the nav is translucent. but in this case there is a
        // problem with the shadow on large titles
        if self.navigationController?.navigationBar.isTranslucent ?? true {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        }
        
        self.navigationController?.navigationBar.tintColor = navigationcolorElement
        self.navigationItem.rightBarButtonItem?.tintColor = navigationcolorElement
        self.navigationController?.navigationBar.backgroundColor = color
        //UIApplication.shared.statusBarView?.backgroundColor = color
        if let statusBarView = UIApplication.shared.statusBarView {
            statusBarView.backgroundColor = color
        }
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: navigationcolorTitle]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navigationcolorTitle]
        self.navigationController?.navigationBar.barStyle = .default
        self.navBarImageTransparency(alpha: navBarTitleAlpha)

        self.refreshStatusBar(style: .default)
    }
    
    /**
     *
     * Method to set the Navigation Bar to a transparent style
     *
     */
    func transparentNavigationBarStyle(){
        
        self.switchNavigationBarShadow(opacity: false)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        let color = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        self.navigationController?.navigationBar.backgroundColor = color
        //UIApplication.shared.statusBarView?.backgroundColor = .clear
        if let statusBarView = UIApplication.shared.statusBarView {
            statusBarView.backgroundColor = .clear
        }
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:color]
        self.refreshStatusBar(style: .lightContent)
        self.navBarImageTransparency(alpha: 0.0)
    }
    
    // METHOD for setting Navigation Bar Shadow visible or invisible
    func switchNavigationBarShadow(opacity:Bool){
        if (opacity && self.navigationController?.navigationBar.shadowImage != nil) {
            self.navigationController?.navigationBar.shadowImage = nil
        } else if (!opacity && self.navigationController?.navigationBar.shadowImage == nil) {
            self.navigationController?.navigationBar.shadowImage = UIImage()
        }
    }
    
    /**
     *
     * Method to control the alpha channel of the ImageView in the navigationBar
     *
     */
    private func navBarImageTransparency(alpha: CGFloat) {
        navigationItem.titleView?.alpha = alpha
    }
}


*/
