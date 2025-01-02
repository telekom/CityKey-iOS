//
//  SCUtilities.swift
//  SmartCity
//
//  Created by Michael on 17.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

// avoid all print and debug print on devices
#if !arch(x86_64) && !arch(i386)

public func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n"){
    
}

public func print(_ items: Any..., separator: String = " ", terminator: String = "\n"){
    
}

#endif

protocol SCUtilityUsable: AnyObject {
    func topViewController()-> UIViewController
    func dismissAnyPresentedViewController(completion: @escaping (() -> Void))
    func dismissPresentedViewControllers(completion: @escaping (() -> Void?))
    func indexForServiceController() -> Int?
    func lockOrientation(_ orientation: UIInterfaceOrientationMask)
    func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation)
}

/**
 * This class contains a lot of useful methods
 */
class SCUtilities: NSObject, SCUtilityUsable {
    
    // Delayed excution for Blocks
    static func delay(withTime: Double, callback: @escaping () -> Void) {
        let when = DispatchTime.now() + withTime
        DispatchQueue.main.asyncAfter(deadline: when) {
            callback()
        }
    }
    
    /**
     * This method return the currently displayed top view Controller
     */
    static func topViewController()-> UIViewController{
        if var topViewController: UIViewController = UIApplication.shared.keyWindow?.rootViewController {
            while ((topViewController.presentedViewController) != nil) {
                topViewController = topViewController.presentedViewController!;
            }

            return topViewController
        }

        // if window is nil. logic to handle app crash on clicking push notification.
        if UIApplication.shared.keyWindow == nil {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = SCInjector().getMainTabBarController()
            window.makeKeyAndVisible()
            return SCInjector().getMainTabBarController()
        } else { // if root view controller is nil
            return SCInjector().getMainTabBarController()
        }
    }
    
    func topViewController()-> UIViewController {
        if var topViewController: UIViewController = UIApplication.shared.keyWindow?.rootViewController {
            while ((topViewController.presentedViewController) != nil) {
                topViewController = topViewController.presentedViewController!;
            }

            return topViewController
        }

        // if window is nil. logic to handle app crash on clicking push notification.
        if UIApplication.shared.keyWindow == nil {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.rootViewController = SCInjector().getMainTabBarController()
            window.makeKeyAndVisible()
            return SCInjector().getMainTabBarController()
        } else { // if root view controller is nil
            return SCInjector().getMainTabBarController()
        }
    }
    
    /**
     * This method return the currently displayed top view Controller ignoring alert views
     */
    static func topViewController(ignoreAlertController : Bool)-> UIViewController{
        var topViewController:UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        
        while ((topViewController.presentedViewController) != nil) {
            if !ignoreAlertController || topViewController.presentedViewController?.isKind(of: UIAlertController.self) == false {
                topViewController = topViewController.presentedViewController!;
            }
        }
        
        return topViewController
    }
    
    static func dismissAnyPresentedViewController(completion: @escaping (() -> Void?)) {
        if SCUtilities.topViewController() is UITabBarController {
            completion()
        } else if (SCUtilities.topViewController().isKind(of: UIAlertController.self)) {
            SCUtilities.topViewController().dismiss(animated: true, completion: {
                if !(SCUtilities.topViewController() is UITabBarController) {
                    dismissPresentedViewControllers(completion: completion)
                } else {
                    completion()
                }
            })
        } else {
            dismissPresentedViewControllers(completion: completion)
        }
    }
    
    func dismissAnyPresentedViewController(completion: @escaping (() -> Void)) {
        if topViewController() is UITabBarController {
            completion()
        } else if (topViewController().isKind(of: UIAlertController.self)) {
            topViewController().dismiss(animated: true, completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                if !(strongSelf.topViewController() is UITabBarController) {
                    strongSelf.dismissPresentedViewControllers(completion: completion)
                } else {
                    completion()
                }
            })
        } else {
            dismissPresentedViewControllers(completion: completion)
        }
    }
    
    func dismissPresentedViewControllers(completion: @escaping (() -> Void?)) {
        let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController
        let navigationController = tabBarController?.selectedViewController as? UINavigationController
        navigationController?.viewControllers.first?.dismiss(animated: true, completion: { //dismisses all presented view controllers
            completion()
        })
    }
    
    static func dismissPresentedViewControllers(completion: @escaping (() -> Void?)) {
        let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController
        let navigationController = tabBarController?.selectedViewController as? UINavigationController
        navigationController?.viewControllers.first?.dismiss(animated: true, completion: { //dismisses all presented view controllers
            completion()
        })
    }

    static func indexForServiceController() -> Int? {
        if let mainTabBarController = SCUtilities.topViewController() as? UITabBarController {
            if let inboxIndex = (mainTabBarController.viewControllers?.firstIndex(where: {
                let viewController = $0 as? UINavigationController
                return viewController?.viewControllers.first is SCServicesDisplaying
                
            })) {
                return inboxIndex
            }
        }
        
        return nil
    }
    
    func indexForServiceController() -> Int? {
        if let mainTabBarController = SCUtilities.topViewController() as? UITabBarController {
            if let inboxIndex = (mainTabBarController.viewControllers?.firstIndex(where: {
                let viewController = $0 as? UINavigationController
                return viewController?.viewControllers.first is SCServicesDisplaying
                
            })) {
                return inboxIndex
            }
        }
        
        return nil
    }
    
    /**
     * This method returns the preffered content language
     */
    static func preferredContentLanguage() -> String {
        
        // check if the top preferred langaug in the device settings is supported
        let firstPreferredContains = GlobalConstants.kSupportedContentLanguages.contains(where: { $0 == Bundle.main.preferredLocalizations.first! })

        if firstPreferredContains {
            return Bundle.main.preferredLocalizations.first!.lowercased()
        } else {
            for prefLangSettings in Bundle.main.preferredLocalizations{
                let langFound = GlobalConstants.kSupportedContentLanguages.contains(where: { $0 == prefLangSettings })
                if langFound {
                    return prefLangSettings.lowercased()
                }
            }
        }
        return "en"
    }

    /**
     * This method returns the current App version and Environment
     */
    static func currentVersionAndEnv()-> String{
        
        let appVersion = SCVersionHelper.appVersion()
        let revision = Bundle.main.infoDictionary!["CFBundleVersion"] as? String

#if RELEASE
        return "App Version: \(appVersion) (\(revision ?? ""))"
#else
        return "App Version: \(appVersion)(\(revision ?? "")-\(currentEnvironment()))"
#endif
    }

    static func currentEnvironment() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "app version not detected"
        if let shortenedAppCenterVersion = version.components(separatedBy: "-").last {
            return shortenedAppCenterVersion
        }

        return "Int"
    }

    static func isInternetAvailable() -> Bool{
        let status = SCReachability().connectionStatus()
        
        switch status {
        case .unknown, .offline:
            return false
        case .online(.wwan),.online(.wiFi):
            return true
        }
    }

    static func clearGMSCache(){
        if ( !UserDefaults.standard.bool(forKey: "CKGMS_Cache_Cleared") ) {
          let googleMapsCachePath = "\(NSHomeDirectory())/Library/Caches/com.t-systems.citykey.dev.GMSCacheStorage/"
          do {
            try FileManager.default.removeItem(atPath: googleMapsCachePath)
            UserDefaults.standard.set(true, forKey: "CKGMS_Cache_Cleared")
          }
          catch (let error){
              debugPrint("Error clearning Google Maps Cache : \(error)")
          }
        }
    }
    
    static func applicationState() -> String {
        
        switch UIApplication.shared.applicationState {
        case .active:
            return "active"
        case .background:
            return "background"
        case .inactive:
            return "inactive"
        default:
            return "unknown"
        }
    }
    
    static func getAppGroupId() -> String {
        return "group.com.telekom.opensource.citykey"
    }
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }

    static func fontSize(for contentSizeCategory: UIContentSizeCategory) -> String {
        let contentSizeCategory = UIApplication.shared.preferredContentSizeCategory
        let sizeCategory = contentSizeCategory
        var scaleFactor: CGFloat = 1.0
        var baseSize: CGFloat = 14.0
        
        switch sizeCategory {
        case .extraSmall:
            scaleFactor = 0.8
        case .small:
            scaleFactor = 0.9
        case .medium:
            scaleFactor = 1.0
        case .large:
            scaleFactor = 1.1
        case .extraLarge:
            scaleFactor = 1.2
        case .extraExtraLarge:
            scaleFactor = 1.3
        case .extraExtraExtraLarge:
            scaleFactor = 1.4
        case .accessibilityMedium:
            scaleFactor = 1.5
        case .accessibilityLarge:
            scaleFactor = 1.6
        case .accessibilityExtraLarge:
            scaleFactor = 1.7
        case .accessibilityExtraExtraLarge:
            scaleFactor = 1.8
        case .accessibilityExtraExtraExtraLarge:
            scaleFactor = 1.9
        default:
            scaleFactor = 1.0
        }
        return "\(baseSize * scaleFactor)px"
    }
    
    static func getHeaderStringWith(level: Int) -> String {
        let header = LocalizationKeys.Common.accessbilityHeadingLevel.localized().replaceStringFormatter()
        return String(format: header, arguments: ["\(level)"])
    }
    
    static func getWebViewAppearanceJS(webViewBackgroundColor: UIColor? = UIColor.white,
                                       webViewFontColor: UIColor? = UIColor.black,
                                       anchorColor: UIColor? = kColor_cityColor) -> String {
        let backgroundColor = webViewBackgroundColor ?? UIColor.white
        let fontColor = webViewFontColor ?? UIColor.black
        let anchorColor = anchorColor ?? kColor_cityColor
        return """
           var style = document.createElement('style');
           style.textContent = '* { background-color: \(backgroundColor.hexDecimalString) !important;
           color: \(fontColor.hexDecimalString) !important; }
           a { color: \(anchorColor.hexDecimalString) !important; }';
           document.head.appendChild(style);
           """
    }
}
