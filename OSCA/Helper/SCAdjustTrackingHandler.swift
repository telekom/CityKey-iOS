/*
Created by Michael on 20.01.20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import AdjustSdk
import MoEngageInApps

protocol SCAdjustTrackingProviding {
    func trackEvent(eventName: String)
    func appWillOpen(url: URL)
}

class SCAdjustTrackingHandler: NSObject, SCAdjustTrackingProviding, AdjustDelegate {

    // MARK: - INITIALIZER

    init(privacySettingsProvider : SCAppContentPrivacySettingsOberserving) {
        super.init()
                
        // catch all privacy setting changes
        privacySettingsProvider.observePrivacySettings(completion: { [weak self ] (moengageOptOut, adjustOptOut) in
            guard let weakSelf = self else { return }
            weakSelf.updateAdjustDataPrivacySetting(optOut: adjustOptOut)
        })

        // TODO: Set the Adjust environment to ADJEnvironmentProduction for all environment
        let environment = ADJEnvironmentProduction

        // set app group for rich notifications
        if let appToken = Config.shared.adjustIdentifier {
            if let adjustConfig = ADJConfig(appToken: appToken, environment: environment){
                // Change the log level.
                #if RELEASE
                adjustConfig.logLevel = ADJLogLevel.suppress
                #else
                adjustConfig.logLevel = ADJLogLevel.verbose
                #endif
                
                // disbales the IDFA reading for Adjust ( SMARTC-17528 )
                adjustConfig.disableIdfaReading()
                
                // Send in the background.
                adjustConfig.enableSendingInBackground()
                
                // Disable event buffering.
//                adjustConfig.eventBufferingEnabled = false
                
                // Set delegate object.
                adjustConfig.delegate = self

                // Initialise the SDK.
                Adjust.initSdk(adjustConfig)
               
                // Set app secret
//                #if RELEASE
//                adjustConfig.setAppSecret(UInt(AnalyticsKeys.TrackedParamValues.Release.adjustAppSecretInfo0),
//                                          info1: UInt(AnalyticsKeys.TrackedParamValues.Release.adjustAppSecretInfo1),
//                                          info2: UInt(AnalyticsKeys.TrackedParamValues.Release.adjustAppSecretInfo2),
//                                          info3: UInt(AnalyticsKeys.TrackedParamValues.Release.adjustAppSecretInfo3),
//                                          info4: UInt(AnalyticsKeys.TrackedParamValues.Release.adjustAppSecretInfo4))
//                
//                #else
//                adjustConfig.setAppSecret(UInt(AnalyticsKeys.TrackedParamValues.QA.adjustAppSecretInfo0),
//                                          info1: UInt(AnalyticsKeys.TrackedParamValues.QA.adjustAppSecretInfo1),
//                                          info2: UInt(AnalyticsKeys.TrackedParamValues.QA.adjustAppSecretInfo2),
//                                          info3: UInt(AnalyticsKeys.TrackedParamValues.QA.adjustAppSecretInfo3),
//                                          info4: UInt(AnalyticsKeys.TrackedParamValues.QA.adjustAppSecretInfo4))
//                
//                #endif
                
//                Adjust.setOfflineMode(true) // Enables offline mode

                // Set data residency
                let domain = ["eu.adjust.com"]
                adjustConfig.setUrlStrategy(domain, useSubdomains: true, isDataResidency: true)
                
//                adjustConfig.deactivateSKAdNetworkHandling()

                self.updateAdjustDataPrivacySetting(optOut: privacySettingsProvider.privacyOptOutAdjust)
                
            }
        }
        
    }

    // MARK: - METHODS

    internal func updateAdjustDataPrivacySetting(optOut: Bool){
        optOut ? Adjust.disable() : Adjust.enable()
    }

    func trackEvent(eventName: String) {
        if let eventToken = self.eventTokenFor(eventName), let event = ADJEvent(eventToken: eventToken){
            
            var parameters = [String:String]()
            parameters[AnalyticsKeys.TrackedParamKeys.citySelected] = kSelectedCityName
            parameters[AnalyticsKeys.TrackedParamKeys.cityId] = kSelectedCityId
            parameters[AnalyticsKeys.TrackedParamKeys.userStatus] = SCAuth.shared.isUserLoggedIn() ? AnalyticsKeys.TrackedParamKeys.loggedIn : AnalyticsKeys.TrackedParamKeys.notLoggedIn
            if SCAuth.shared.isUserLoggedIn(), let userProfile = SCUserDefaultsHelper.getProfile() {
                parameters[AnalyticsKeys.TrackedParamKeys.userZipcode] = userProfile.postalCode
                parameters[AnalyticsKeys.TrackedParamKeys.registeredCityName] = userProfile.cityName
                parameters[AnalyticsKeys.TrackedParamKeys.registeredCityId] = "\(userProfile.homeCityId)"
            }
            
            for dict in parameters {
                event.addCallbackParameter(dict.key, value: dict.value)
                event.addPartnerParameter(dict.key, value: dict.value)
            }
    
            Adjust.adid { adid in
                guard let adid = adid else {
                    return
                }
                event.addPartnerParameter(AnalyticsKeys.TrackedParamKeys.moengageCustomerId, value: adid)
                event.addPartnerParameter(AnalyticsKeys.TrackedParamKeys.adjustDeviceId, value: adid)
                Adjust.trackEvent(event)
            }
            MoEngageSDKInApp.sharedInstance.setCurrentInAppContexts([eventName])
            MoEngageSDKInApp.sharedInstance.showInApp()
        }
    }

    func trackEvent(eventName: String, parameters: [String : String]) {
        if let eventToken = self.eventTokenFor(eventName), let event = ADJEvent(eventToken: eventToken){
            var commonParamerters = [String:String]()
            if SCAuth.shared.isUserLoggedIn(), let userProfile = SCUserDefaultsHelper.getProfile() {
                commonParamerters[AnalyticsKeys.TrackedParamKeys.registeredCityName] = userProfile.cityName
                commonParamerters[AnalyticsKeys.TrackedParamKeys.registeredCityId] = "\(userProfile.homeCityId)"
            }
            let param = parameters.merging(commonParamerters) { param, commomParam in param }

            for dict in param {
                event.addCallbackParameter(dict.key, value: dict.value)
                event.addPartnerParameter(dict.key, value: dict.value)
            }
            
            Adjust.adid { adid in
                guard let adid = adid else {
                    return
                }
                Adjust.trackEvent(event)
            }
            MoEngageSDKInApp.sharedInstance.setCurrentInAppContexts([eventName])
            MoEngageSDKInApp.sharedInstance.showInApp()
        }
    }
    
    func appWillOpen(url: URL) {
        if let adjUrl = ADJDeeplink(deeplink: url) {
            Adjust.processDeeplink(adjUrl)
        }
    }
    
    // MARK: - Mapping EventName To EvenToken

    func eventTokenFor(_ eventName : String) -> String? {
        if let fileName = Bundle.main.infoDictionary?["SCAdjustTokens"] as? String, !fileName.isEmpty {
            let path = Bundle.main.path(forResource: fileName, ofType: "plist")
            let dictionary = NSDictionary(contentsOfFile: path!)
            let tokenDictionary: [String: String] = dictionary as! [String: String]
            return tokenDictionary[eventName]
        }
        return ""
    }

    // MARK: - Delegate

    func adjustAttributionChanged(_ attribution: ADJAttribution?) {
        debugPrint("Attribution callback called!")
        debugPrint("Attribution: %@", attribution ?? "")
    }

    func adjustEventTrackingSucceeded(_ eventSuccessResponseData: ADJEventSuccess?) {
        debugPrint("Event success callback called!")
        debugPrint("Event success data: %@", eventSuccessResponseData ?? "")
    }

    func adjustEventTrackingFailed(_ eventFailureResponseData: ADJEventFailure?) {
        debugPrint("Event failure callback called!")
        debugPrint("Event failure data: %@", eventFailureResponseData ?? "")
    }

    func adjustSessionTrackingSucceeded(_ sessionSuccessResponseData: ADJSessionSuccess?) {
        debugPrint("Session success callback called!")
        debugPrint("Session success data: %@", sessionSuccessResponseData ?? "")
    }

    func adjustSessionTrackingFailed(_ sessionFailureResponseData: ADJSessionFailure?) {
        debugPrint("Session failure callback called!");
        debugPrint("Session failure data: %@", sessionFailureResponseData ?? "")
    }

    func adjustDeeplinkResponse(_ deeplink: URL?) -> Bool {
        debugPrint("Deferred deep link callback called!")
        debugPrint("Deferred deep link URL: %@", deeplink?.absoluteString ?? "")
        return true
    }
    
    internal func eraseUserDataViaGdprForgetMe(){
        Adjust.gdprForgetMe()
    }
    
    internal func updateThirdPartySharingSetting(optOut: Bool){
        
        // Set isEnabledNumberBool value to true for enable and false to disable sharing the user's data with third-parties
        if let adjustThirdPartySharing = ADJThirdPartySharing.init(isEnabled: !optOut as NSNumber){
            Adjust.trackThirdPartySharing(adjustThirdPartySharing)
        }
    }
    
    internal func sendGranularInformationToAdjust(partnerName: String, key: String, value: String){
        
        if let adjustThirdPartySharing = ADJThirdPartySharing.init(isEnabled: nil) {
            adjustThirdPartySharing.addGranularOption(partnerName, key: key, value: value)
            Adjust.trackThirdPartySharing(adjustThirdPartySharing)
        }
    }
    
    internal func disableThirdPartySharing() {
        if let adjustThirdPartySharing = ADJThirdPartySharing.init(isEnabled: false) {
            Adjust.trackThirdPartySharing(adjustThirdPartySharing)
        }
    }
    
    internal func updateConsetMeasurementSetting(optOut: Bool){
        // Set true to enable and false to disable
        Adjust.trackMeasurementConsent(!optOut) // true
    }

}
