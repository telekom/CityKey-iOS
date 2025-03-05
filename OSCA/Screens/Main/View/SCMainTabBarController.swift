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
import AudioToolbox

class SCMainTabBarController: UITabBarController {
    
    public var presenter: SCMainPresenting!

    private var completeTabBarControllers: [UIViewController]? // we need to save them to restore them
    
    private var activityScreenLayer : UIView?
    private var loadVC: SCLoadViewController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.completeTabBarControllers = self.viewControllers
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        
        self.setupViewControllers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.presenter.viewWillAppear()
        self.refreshNavigationBarStyle()

        self.selectedViewController?.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        // get the preferredStatusBarStyle from the selected viewcontroller 
        if let selVC = self.selectedViewController{

            if let navControl = selVC as? UINavigationController {
                if  navControl.viewControllers.count > 0 {
                    let test = navControl.viewControllers[0]
                    return test.preferredStatusBarStyle
                }
            } else {
                 return selVC.preferredStatusBarStyle
            }

        }
        return .lightContent
    }
    
    override var childForStatusBarStyle : UIViewController? {
        // By returning nil from childViewControllerForStatusBarStyle() the tab bar controller will look at
        // its own preferredStatusBarStyle() method
        return nil
    }
    
    private func setupViewControllers() {
        guard let viewControllers = self.viewControllers else {
            debugPrint("SCMainTabBarController->setupViewControllers: NO viewControllers")
            return
        }
        self.presenter.injectPresenters(into: viewControllers)
    }
}

extension SCMainTabBarController: SCMainDisplaying {
    
    func navigationController() -> UINavigationController? {
        return self.navigationController
    }

    func selectedController() -> UIViewController? {
        return self.selectedViewController
    }

    func present(viewController: UIViewController){
        debugPrint("viewController", viewController)
        self.present(viewController, animated: true, completion: nil)
    }
    
    func restoreAllTabs() {
        self.viewControllers = self.completeTabBarControllers
    }
    
    func removeTab(for itemType: SCMainTabBarItemType) {
        guard let itemToBeRemoved = self.getTabBarItem(itemType),
            let indexToBeRemoved = self.tabBar.items?.firstIndex(of: itemToBeRemoved),
            self.viewControllers?.count ?? 0 > indexToBeRemoved else {
                debugPrint("SCMainTabBarController->removeTab: no tab or vc found for removal", itemType)
                return
        }
        self.viewControllers?.remove(at: indexToBeRemoved)
    }
    
    func setTabBarItemTitle(_ title: String, for itemType: SCMainTabBarItemType) {
        if let tabBarItems = self.tabBar.items {
            tabBarItems[itemType.rawValue].title = title
            tabBarItems[itemType.rawValue].tag = itemType.rawValue
        }
    }
    
    func setTabBarColor(_ color: UIColor) {
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = color
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY") ?? .gray]
            tabBar.standardAppearance = appearance
            if #available(iOS 15.0, *) {
                tabBar.scrollEdgeAppearance = appearance
            }
        }
        self.tabBar.tintColor = color
    }
    
    func setTabBarItemBadge(for itemType: SCMainTabBarItemType, value: Int, color: UIColor) {
        if let itemToBeBadged = self.getTabBarItem(itemType) {
            itemToBeBadged.badgeValue = value > 0 ? String(value) : nil
            itemToBeBadged.badgeColor = color
        }
    }
    
    func showActivityLayer(_ show : Bool){
        if show && self.activityScreenLayer == nil {
            // Add activity screen o show the activity
            self.loadVC = UIStoryboard(name: "LoadScreen", bundle: nil).instantiateViewController(withIdentifier: "SCLoadViewController") as? SCLoadViewController
            self.activityScreenLayer = loadVC?.view
            self.activityScreenLayer?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.activityScreenLayer?.frame = self.view.bounds
            self.view.addSubview(self.activityScreenLayer!)
        }
        
        if !show && self.activityScreenLayer != nil {
            // Remove activity screen o show the activity
            self.loadVC?.loadCompletionHandler = {
                self.activityScreenLayer?.removeFromSuperview()
                self.activityScreenLayer = nil
                self.loadVC = nil
            }
            self.loadVC?.finishLoading()
        }
    }
    
    
    private func getTabBarItem(_ itemType: SCMainTabBarItemType) -> UITabBarItem? {
        if let tabBarItems = self.tabBar.items {
            for tabBarItem in tabBarItems {
                if tabBarItem.tag == itemType.rawValue {
                    return tabBarItem
                }
            }
        }
        return nil
    }

}
