//
//  SCMainTabBarController
//  SmartCity
//
//  Created by Michael on 05.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

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
