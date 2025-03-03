/*
Created by A106551118 on 18/10/22.
Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, A106551118
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import MoEngageSDK
import MoEngageInApps
import AdjustSdk

protocol MoEngageAnalyticsTracking {
    func initializeMoengage(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?)
    func setupMoEngageUserAttributes()
}

class SCMoEngageAnalyticsHandler: NSObject, MoEngageAnalyticsTracking {

    init(privacySettingsProvider : SCAppContentPrivacySettingsOberserving) {
        
        super.init()

        // catch all privacy setting changes
        privacySettingsProvider.observePrivacySettings(completion: { [weak self ] (moengageOptOut, adjustOptOut) in
            guard let weakSelf = self else { return }
            weakSelf.updateMoEngageDataPrivacySetting(optOut: moengageOptOut)
        })
        
        /// MoEngage IDFA and IDFV OptOuts
        MoEngageSDKAnalytics.sharedInstance.disableIDFATracking() //Opt out
        MoEngageSDKAnalytics.sharedInstance.disableIDFVTracking() //Opt out
    }
    
    func initializeMoengage(_ application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        // set app group for rich notifications
        //        if let appGroupID = Bundle.main.infoDictionary?["SCCityKeyAppGroup"] as? String {
        if let appGroupID = Config.shared.moEngageAppGroup, let moengageIdentifier = Config.shared.moEngageIdentifier {
            
            //For SDK version 9.17.1
            let sdkConfig = MoEngageSDKConfig(appId: moengageIdentifier,
                                              dataCenter: .data_center_02) //"MoEngage App ID and data center")
            sdkConfig.appGroupID = appGroupID
            
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
        
        MoEngageSDKAnalytics.sharedInstance.enableDataTracking() //Opt in
        
        //For tracking if it's a new install or on update by user
        self.sendAppStatusToMoEngage()
        self.saveAppVersionToDefaults()

        /// MoEngage IDFA and IDFV OptOuts
        MoEngageSDKAnalytics.sharedInstance.disableIDFATracking() //Opt out
        MoEngageSDKAnalytics.sharedInstance.disableIDFVTracking() //Opt out
        
        MoEngage.sharedInstance.enableSDK()

        // Setup MoEngage In-App messaging
        setupMoEngageInAppMessaging()
    }
    
    func setupMoEngageUserAttributes() {
        let userProfile = SCUserDefaultsHelper.getProfile()
//        MOAnalytics.sharedInstance.setEmailID(userProfile?.email ?? "")
//        MOAnalytics.sharedInstance.setDateOfBirth(userProfile?.birthdate ?? Date()) don't send sensitive data to thrird party provider
        Adjust.adid { adid in
            if let adid = adid {
                MoEngageSDKAnalytics.sharedInstance.setUniqueID(adid)
                MoEngageSDKAnalytics.sharedInstance.setUserAttribute(adid, withAttributeName: AnalyticsKeys.TrackedParamKeys.moengageCustomerId)
            }
            
            if SCAuth.shared.isUserLoggedIn(),
               let userProfile = userProfile {
                MoEngageSDKAnalytics.sharedInstance.setUserAttribute(userProfile.homeCityId, withAttributeName: AnalyticsKeys.TrackedParamKeys.registeredCityId)
                MoEngageSDKAnalytics.sharedInstance.setUserAttribute(userProfile.cityName, withAttributeName: AnalyticsKeys.TrackedParamKeys.registeredCityName)
            }
            MoEngageSDKAnalytics.sharedInstance.setUserAttribute(kSelectedCityId, withAttributeName: AnalyticsKeys.TrackedParamKeys.cityId)
            MoEngageSDKAnalytics.sharedInstance.setUserAttribute(kSelectedCityName, withAttributeName: AnalyticsKeys.TrackedParamKeys.citySelected)
            
        }
    }
        
    private func sendAppStatusToMoEngage() {
        if((UserDefaults.standard.object(forKey: "app version") == nil)) {
            //For Fresh Install of App
            MoEngageSDKAnalytics.sharedInstance.appStatus(.install)
            return
        }
        let currentVersion = getAppVersion().trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)
        let previousVersion = (UserDefaults.standard.object(forKey: "app version") as AnyObject).trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.").inverted)
        if(currentVersion > previousVersion) {
            // For Existing user who has updated the app
            MoEngageSDKAnalytics.sharedInstance.appStatus(.update)
        }
    }
    
    private func saveAppVersionToDefaults () {
        UserDefaults.standard.set(self.getAppVersion(), forKey: "app version")
    }
    
    private func getAppVersion () -> AnyObject {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")! as AnyObject
    }
    
    internal func updateMoEngageDataPrivacySetting(optOut: Bool){
        MoEngageSDKAnalytics.sharedInstance.disableDataTracking() //Opt out
    }
    
    func setupMoEngageInAppMessaging() {
        //MARK: MoEngage In-App messages
        MoEngageSDKInApp.sharedInstance.setInAppDelegate(self)
        MoEngageSDKInApp.sharedInstance.showInApp()
    }

}

//MARK: MoEngage In-App messages - MoEngageInAppNativeDelegate delegate
extension SCMoEngageAnalyticsHandler : MoEngageInAppNativeDelegate {
    func inAppClicked(withCampaignInfo inappCampaign: MoEngageInApps.MoEngageInAppCampaign, andNavigationActionInfo navigationAction: MoEngageInApps.MoEngageInAppNavigationAction, forAccountMeta accountMeta: MoEngageCore.MoEngageAccountMeta) {
        print("InApp Clicked with Campaign ID \(inappCampaign.campaignId)")
        print("Navigation Action \(String(describing: navigationAction.actionType)) Key Value Pairs: \((navigationAction.keyValuePairs))")
    }
    
    
    // Called when an inApp is shown on the screen
    func inAppShown(withCampaignInfo inappCampaign: MoEngageInAppCampaign, forAccountMeta accountMeta: MoEngageAccountMeta) {
       print("InApp shown callback for Campaign ID(\(inappCampaign.campaignId)) and CampaignName(\(inappCampaign.campaignName))")
       print("Account Meta AppID: \(accountMeta.appID)")
        
        //MARK: MoEngage In-App messages - show thank you message
        SCUtilities.topViewController().showUIAlert(with: "Thank you for using the app!!!")
    }

    // Called when an inApp is dismissed by the user
    func inAppDismissed(withCampaignInfo inappCampaign: MoEngageInAppCampaign, forAccountMeta accountMeta: MoEngageAccountMeta) {
        print("InApp dismissed callback for Campaign ID(\(inappCampaign.campaignId)) and CampaignName(\(inappCampaign.campaignName))")
        print("Account Meta AppID: \(accountMeta.appID)")
    }

    // Called when an inApp is clicked by the user, and it has been configured with a custom action
    func inAppClicked(withCampaignInfo inappCampaign: MoEngageInAppCampaign, andCustomActionInfo customAction: MoEngageInAppAction, forAccountMeta accountMeta: MoEngageAccountMeta) {
         print("InApp Clicked with Campaign ID \(inappCampaign.campaignId)")
         print("Custom Actions Key Value Pairs: \(customAction.keyValuePairs)")
    }

    // Called when an inApp is clicked by the user, and it has been configured with a navigation action
    func inAppClicked(withCampaignInfo inappCampaign: MoEngageInAppCampaign, andNavigationActionInfo navigationAction: MoEngageInAppAction, forAccountMeta accountMeta: MoEngageAccountMeta) {
        print("InApp Clicked with Campaign ID \(inappCampaign.campaignId)")
        print("Navigation Action Screen Name \(String(describing: navigationAction.actionType)) Key Value Pairs: \((navigationAction.keyValuePairs))")
    }
    
    func selfHandledInAppTriggered(withInfo inappCampaign: MoEngageInApps.MoEngageInAppSelfHandledCampaign, forAccountMeta accountMeta: MoEngageCore.MoEngageAccountMeta) {
        
    }
}
