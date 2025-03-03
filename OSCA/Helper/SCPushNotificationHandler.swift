/*
Created by Michael on 11.12.18.
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
import UserNotifications
import AudioToolbox
import MoEngageSDK
import AdjustSdk

protocol SCPushNotificationProviding {
    func initializeMoEngageForApplication(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    func registerPushForApplication()
    func refreshMoEngageStatusWithUserID(_ userid : String?)
    func refreshMoEngageStatusWithCityID(_ cityid : String?)

}

class SCPushNotificationHandler : NSObject, SCPushNotificationProviding, UNUserNotificationCenterDelegate {
    
    private var pushRegisterd : Bool = false
    private var refreshHandler: SCSharedWorkerRefreshHandling
    private let privacySettingsProvider : SCAppContentPrivacySettingsOberserving
    static var pushDeviceToken : String?
    private let deeplinkHandler: SCDeeplinkingHanding
    private let userContentSharedWorker: SCUserContentSharedWorking

    static func isPushEnabled(completion: @escaping (_ enabled: Bool) ->()) {
         let center = UNUserNotificationCenter.current()
         center.getNotificationSettings { settings in
             completion (settings.authorizationStatus == .authorized)
         }
     }

    init(userIDProvider : SCUserContentUserIdentifing,
         privacySettingsProvider : SCAppContentPrivacySettingsOberserving,
         refreshHandler: SCSharedWorkerRefreshHandling,
         deeplinkHandler: SCDeeplinkingHanding = SCDeeplinkingHandler.shared,
         userContentSharedWorker: SCUserContentSharedWorking) {
        
        self.privacySettingsProvider = privacySettingsProvider
        self.refreshHandler = refreshHandler
        self.deeplinkHandler = deeplinkHandler
        self.userContentSharedWorker = userContentSharedWorker
        super.init()

        // catch all USERID changes
        userIDProvider.observeUserID(completion: { [weak self ] (userID) in
            guard let weakSelf = self else { return }

            weakSelf.refreshMoEngageStatusWithUserID(userID)
        })
        
        // catch all CITYID changes
        userIDProvider.observeCityID(completion: { [weak self ] (cityID) in
            guard let weakSelf = self else { return }

            weakSelf.refreshMoEngageStatusWithCityID(cityID)
        })

        // catch all privacy setting changes
        privacySettingsProvider.observePrivacySettings(completion: { [weak self ] (moengageOptOut, adjustOptOut) in
            guard let weakSelf = self else { return }
            weakSelf.updateMoEngageDataPrivacySetting(optOut: moengageOptOut)
        })
      
        /// MoEngage IDFA and IDFV OptOuts
        MoEngageSDKAnalytics.sharedInstance.disableIDFATracking() //Opt out
        MoEngageSDKAnalytics.sharedInstance.disableIDFVTracking() //Opt out
        
    }

    func initializeMoEngageForApplication(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?){
        UNUserNotificationCenter.current().delegate = self
        
        // set app group for rich notifications
        //        if let appGroupID = Bundle.main.infoDictionary?["SCCityKeyAppGroup"] as? String {
        if let appGroupID = Config.shared.moEngageAppGroup,
            let moengageIdentifier = Config.shared.moEngageIdentifier {
            
            //For SDK version 7.0.0 and above
            let sdkConfig = MoEngageSDKConfig.init(withAppID: moengageIdentifier) //"MoEngage App ID")
            sdkConfig.appGroupID = appGroupID
            sdkConfig.moeDataCenter = .data_center_02
            
            //MARK: Enable MoEngage logs for debug and int environment
            #if DEBUG || INT
            sdkConfig.consoleLogConfig = MoEngageConsoleLogConfig(isLoggingEnabled: true, loglevel: .verbose)
            #endif
            
            // Separate initialization methods for Dev and Prod initializations
            #if DEBUG
            MoEngage.sharedInstance.initializeTestInstance(sdkConfig, sdkState: .enabled)
            debugPrint("OSCA PUSH: init dev")
            #else
            MoEngage.sharedInstance.initializeLiveInstance(sdkConfig, sdkState: .enabled)
            debugPrint("OSCA PUSH: init prod")
            #endif
        }
        
        self.updateMoEngageDataPrivacySetting(optOut: self.privacySettingsProvider.privacyOptOutMoEngage)

        /// MoEngage IDFA and IDFV OptOuts
        MoEngageSDKAnalytics.sharedInstance.disableIDFATracking() //Opt out
        MoEngageSDKAnalytics.sharedInstance.disableIDFVTracking() //Opt out
        
    }
    
    func registerPushForApplication(){
        if !pushRegisterd {
            pushRegisterd = true
            MoEngageSDKMessaging.sharedInstance.registerForRemoteNotification(withCategories: nil, andUserNotificationCenterDelegate: self)
        }
    }

    internal func updateMoEngageDataPrivacySetting(optOut: Bool){
        
        MoEngageSDKAnalytics.sharedInstance.disableDataTracking() //Opt out
    }
    
    internal func refreshMoEngageStatusWithUserID(_ userid : String?){
        
        let userProfile = userContentSharedWorker.getUserData()?.profile

        MoEngageSDKAnalytics.sharedInstance.setUserAttribute(kSelectedCityName, withAttributeName: AnalyticsKeys.TrackedParamKeys.citySelected)

        // When the user is not logged in then we will set the user to -1
        let userIDForMoengage = userid != nil && userid!.count > 0 ? userid : "-1"
        if userIDForMoengage != "-1"{
            
            MoEngageSDKAnalytics.sharedInstance.resetUser()
        }
        else{
            // When user logs out , call the logout/reset function on MoEngage
//             MoEngage.sharedInstance().resetUser()
        }
    }
    
    internal func refreshMoEngageStatusWithCityID(_ cityid: String?) {
        // When the user is not logged in then we will set the user to -1
        let cityIDForMoengage = cityid != nil && cityid!.count > 0 ? cityid : "-1"
        if cityIDForMoengage != "-1"{
            MoEngageSDKAnalytics.sharedInstance.setUserAttribute(cityIDForMoengage, withAttributeName: "CK_CITY_ID")
        }
    }
    
    private func getAppVersion () -> AnyObject {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")! as AnyObject
    }

    private func getPushPriority(userInfo: [AnyHashable : Any]) -> SCPushNotificationPriority{
        
        if let appextraTag = userInfo["app_extra"] as? [AnyHashable : Any], let screenData = appextraTag["screenData"] as? [AnyHashable : Any], let oscaPriority = screenData["oscaPriority"] as? String {
            
            switch oscaPriority.uppercased() {
            case "LOW":
                return .low
            case "MEDIUM":
                return .medium
            default:
                return .high
            }
        }
        
        return .high
    }
    
    func didRegisterForRemoteNotificationsWithDeviceToken(_ deviceToken: Data) {
        MoEngageSDKMessaging.sharedInstance.setPushToken(deviceToken)
        let token = deviceToken.reduce("", {$0 + String(format: "%02x", $1)})
        SCPushNotificationHandler.pushDeviceToken = token
    }
    
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        MoEngageSDKMessaging.sharedInstance.didFailToRegisterForPush()
    }


    
    //MARK:- Push Notification delegate Method
    
        
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        SCFileLogger.shared.write("SCPushNotificationHandler -> userNotificationCenter didReceive response : \(response.notification.description)", withTag: .logout)
        MoEngageSDKMessaging.sharedInstance.userNotificationCenter(center, didReceive: response)
        completionHandler()
        let userInfo = response.notification.request.content.userInfo
        let appExtraDictionary = userInfo["app_extra"] as? [String: Any?]
        if let deeplinkURI = appExtraDictionary?["moe_deeplink"] as? String {
            if !deeplinkURI.isEmpty {
                deeplinkHandler.deeplinkWithUri(deeplinkURI)
            }
        }
        
        SCFileLogger.shared.write("SCPushNotificationHandler -> userNotificationCenter didReceive response -> self.refreshHandler.reloadUserInfoBox()  ", withTag: .logout)
        // refresh always the info box messages
        self.refreshHandler.reloadUserInfoBox()

    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        let priority = self.getPushPriority(userInfo: userInfo)
        if priority == .high{
            completionHandler([.alert , .sound])
        } else {
            completionHandler([])
        }
        
        SCFileLogger.shared.write("SCPushNotificationHandler -> userNotificationCenter willPresent notification \(notification.description)", withTag: .logout)
        SCFileLogger.shared.write("SCPushNotificationHandler -> userNotificationCenter willPresent notification  -> self.refreshHandler.reloadUserInfoBox()  ", withTag: .logout)
        // refresh always the info box messages
        self.refreshHandler.reloadUserInfoBox()
    }
    
}
