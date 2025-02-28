//
//  AppDelegate.swift
//  SmartCity
//
//  Created by Michael on 04.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

import GoogleMaps
import KeychainSwift
import AdjustSdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SCDisplaying {

    var window: UIWindow?

    lazy var injector = SCInjector()

    var privacyLayer = SCPrivacyLayer()
    var versionCheckCompletion = {}
    
    var appIsInBackground = false
    var backgroundTaskID : UIBackgroundTaskIdentifier?
    
    enum NotificationType {
        case MoEngage
        case TPNS
    }
    
    let notificationType: NotificationType = .TPNS

    /// set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all
    
    private var userDefaults: UserDefaults {
        return UserDefaults(suiteName: SCUtilities.getAppGroupId()) ?? UserDefaults.standard
    }
    
    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
  
        debugPrint("AppDelegate->open url")
        SCFileLogger.shared.write("AppDelegate -> open url \(url) ", withTag: .logout)
        SCDeeplinkingHandler.shared.deeplinkWithUri(url.absoluteString)
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // APPCENTER INTEGRATION WHEN NOT DEBUG
        #if DEBUG || RELEASE
            // no app center in DEBUG or in the RELEASE version
        #else
        if let appcenterIdentifier = Config.shared.appCenterIdentifier {
            //Distribute.updateTrack = .private
            AppCenter.start(withAppSecret: appcenterIdentifier, services: [Analytics.self, Crashes.self, Distribute.self])
        }
        #endif
        
        // Register for PUSH NOTIFICATION
        SCFileLogger.shared.write("didFinishLaunchingWithOptions -> self.injector.initializeMoEngageForApplication()  ", withTag: .logout)

        //TODO: Added this for Adjust + Moengage POC. Remove this after this
//        MOAnalytics.sharedInstance.optOut(ofMoEngagePushNotification: true)

        SCDeviceUniqueID.shared.saveUniqueIDIfNeeded()
        
        self.injector.initializeNotificationForApplication(application, launchOptions: launchOptions)
        
        //TODO: Added this for Adjust + Moengage POC
        self.injector.initializeMoEngageForApplication(application, launchOptions: launchOptions)
        
        //Hide Autolayout Warning
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // Google Maps
        GMSServices.provideAPIKey(Config.shared.googleMapsAPIKey)

        // Hides the menu that appears when long pressed on back button
        SCBarButtonItemMenuExtension.swizzle()
                
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.rootViewController = self.injector.getMainTabBarController()
            window.makeKeyAndVisible()

            #if RELEASE
            guard !validateIfJailbreakDevice() else {
                return false
            }
            #endif
        }
        SCAppearanceManager.shared.setAppWideCellSelectionColor()
        SCFileLogger.shared.write("didFinishLaunchingWithOptions -> launchOptions : \(String(describing: launchOptions))", withTag: .logout)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.injector.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
        Adjust.setPushToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      self.injector.didFailToRegisterForRemoteNotificationsWithError(error)
    }
    
    private func validateIfJailbreakDevice() -> Bool {
        if UIDevice.current.isJailBroken {
            SCGlobalAlertController(title: "security_alert".localized(), message: "jailbreak_desc".localized(), preferredStyle: .alert).show()
            return true
        } else {
            return false
        }
    }
    
    //
    //MARK:-  UIApplication mehthods
    //

    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        SCFileLogger.shared.write("handleOpenURL \(url)", withTag: .logout)
        self.injector.appWillOpen(url: url)
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        SCFileLogger.shared.write("userActivity restorationHandler", withTag: .logout)
        if (userActivity.activityType == NSUserActivityTypeBrowsingWeb) {
            self.injector.appWillOpen(url: userActivity.webpageURL!)
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        //SCRequestHandler.sharedInstance.cancelAllRequests()
        self.privacyLayer.displayPrivacyLayer(true, isBlurred: true)
        SCFileLogger.shared.write("applicationWillResignActive", withTag: .logout)
   }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // Technical Q&A QA1838
        // Preventing Sensitive Information From Appearing In The Task Switcher
        //
        // Remove sensitive information from views before moving to the background. When an application transitions to the background, the system takes a snapshot of the application’s main window,
        // which it then presents briefly when transitioning your application back to the foreground. Before returning from your applicationDidEnterBackground: method, you should hide or obscure
        // passwords and other sensitive personal information that might be captured as part of the snapshot.
        // https://developer.apple.com/library/archive/qa/qa1838/_index.html
        
        self.privacyLayer.displayPrivacyLayer(true)
        self.appIsInBackground = true
        
//        Reverted code:
//        updateUnreadNotificaitonCountOnAppBadge()
        WidgetUtility().reloadAllTimeLines()
        /*
        // Perform the task on a background queue.
        DispatchQueue.global().async {
            // Request the task assertion and save the ID.
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Finish Network Tasks") {
              
                // End the task if time expires.
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
            }
                 
            // LET'S DO ALL THE STUFF WE NEED TO DO BEFORE BACKGROUNDING
            
            usleep(10000)
            debugPrint("Finished Backgrounding")

           // End the task assertion.
           UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
    }
    */
        
    #if targetEnvironment(simulator)
    let token = userDefaults.string(forKey: "RefreshTokenKey")
    #else
    let token = KeychainHelper().load(key: "RefreshTokenKey")
    #endif
        
        SCFileLogger.shared.write("applicationDidEnterBackground", withTag: .logout)
        SCFileLogger.shared.write("Refresh Token:  \(String(describing: token)) AccessToken: ", withTag: .logout)
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.privacyLayer.displayPrivacyLayer(false)
        SCUtilities.delay(withTime: 1.0, callback: {
            let status = SCReachability().connectionStatus()

            switch status {
            case .unknown, .offline:
                print("Not connected")
                break
            case .online(.wwan),.online(.wiFi):
                print("Connected via WiFi OR WWAN")
            }
        })
        
        SCFileLogger.shared.write("applicationWillEnterForeground", withTag: .logout)
        UserDefaults(suiteName: WidgetUtility().getAppGroupId())?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = -1 // to retain push notifications in notification center
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SCFileLogger.shared.write("applicationDidBecomeActive", withTag: .logout)
        self.privacyLayer.displayPrivacyLayer(false)
        
        if (self.appIsInBackground){
            SCFileLogger.shared.write("applicationDidBecomeActive -> self.appIsInBackground -> postNotification(for: .appMovedToForeground)", withTag: .logout)
            SCDataUIEvents.postNotification(for: .appMovedToForeground)
        } else {
            SCFileLogger.shared.write("applicationDidBecomeActive -> !self.appIsInBackground -> - ", withTag: .logout)
        }
        self.appIsInBackground = false
        WidgetTracker(injector: injector).logWidgetAnalytics()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        SCFileLogger.shared.write("applicationWillTerminate", withTag: .logout)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        // we only need to call the rerfresh when app is currently in foreground
        SCFileLogger.shared.write("didReceiveRemoteNotification \(userInfo)", withTag: .logout)
        if !appIsInBackground{
            SCFileLogger.shared.write("!appIsInBackground -> self.injector.refreshInfoBoxData() ", withTag: .logout)
            self.injector.refreshInfoBoxData()
        } else {
            SCFileLogger.shared.write("appIsInBackground -> - ", withTag: .logout)
        }
        
        SCFileLogger.shared.write("didReceiveRemoteNotification -> completionHandler(.newData) ", withTag: .logout)
        completionHandler(.newData)
    }

    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        SCFileLogger.shared.write("applicationDidReceiveMemoryWarning", withTag: .logout)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    /*
     private func updateUnreadNotificaitonCountOnAppBadge() {
         let content = UNMutableNotificationContent()
         content.badge = (UserDefaults(suiteName: WidgetUtility().getAppGroupId())?.value(forKey: "count") as? NSNumber)
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
         let idNotificacion = UUID().uuidString
         let request = UNNotificationRequest(identifier: idNotificacion, content: content, trigger: trigger)
         let center = UNUserNotificationCenter.current()
         center.add(request) { (error : Error?) in
             if let theError = error {
                 print(theError)
             } else {
                 
             }
         }
     }
     */
}

//extension UIApplication {
//    var statusBarView : UIView? {
//        return value(forKey: "statusBar") as? UIView
//    }
//}

extension UIApplication {

    var statusBarBackgroundColor: UIColor? {
        get {
            return statusBarView?.backgroundColor
        } set {
            statusBarView?.backgroundColor = newValue
        }
    }
    var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 987654321

            if let statusBar = UIApplication.shared.keyWindow?.viewWithTag(tag) {
                return statusBar
            }
            else {
                let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
                statusBarView.tag = tag

                UIApplication.shared.keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else {
            return value(forKey: "statusBar") as? UIView
        }

    }
    
    var adjInjector : SCInjector?{
        return SCInjector()
    }
}
