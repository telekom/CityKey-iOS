/*
Created by Robert Swoboda - Telekom on 23.04.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Robert Swoboda
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import KeychainSwift

enum AppStatus {
    case freshInstall
    case upgrade
    case none
}

class SCVersionHelper {
    
    static func addVersionHeadersTo(_ request: URLRequest) -> URLRequest {
        var modifiedRequest = request
        modifiedRequest.addValue("iOS", forHTTPHeaderField: "OS-Name")
        modifiedRequest.addValue(GlobalConstants.kSupportedServiceAPIVersion, forHTTPHeaderField: "App-Version")
        return modifiedRequest
    }
    
    static func appVersion() -> String {
        // use only the version number before the minus (like 1.0-DEV) or the major and minor verson (like 1.0.0)
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "app version not detected"
        if let shortenedAppCenterVersion = version.components(separatedBy: "-").first {
            return shortenedAppCenterVersion
        }
        let majorVersion = version.components(separatedBy: ".")[0]
        let minorVersion = version.components(separatedBy: ".")[1]
        return majorVersion + "." + minorVersion
    }
    
    static func validateAppVersion(request: SCRequest, injector: SCToolsInjecting) {
        SCFileLogger.shared.write("validateAppVersion", withTag: .logout)
        let versionWorker = SCVersionCheckWorker(requestFactory: request)
        
        versionWorker.checkVersionInfo(completion:{ (error, versionSupported, unspportedVersionMessage) in
            
            DispatchQueue.main.async {
                
                if versionSupported {
                    SCFileLogger.shared.write("validateAppVersion -> versionSupported == true", withTag: .logout)
                } else {
                    SCFileLogger.shared.write("validateAppVersion -> versionSupported == false", withTag: .logout)
                    let forceUpdateVersionVC = injector.getForceUpdateVersionViewController()
                    if #available(iOS 13.0, *) {
                        forceUpdateVersionVC.isModalInPresentation = true
                    } else {
                        // Fallback on earlier versions
                    }
                    SCUtilities.topViewController().present(forceUpdateVersionVC, animated: true, completion: nil)
                }
            }
        })
    }
    
    static func checkAppUpgrade(completionHandler: ((AppStatus)-> Void)?) {
        var appStatus: AppStatus = .none
        let currentVersion = SCVersionHelper.appVersion()
        let versionOfLastRun = UserDefaults.standard.object(forKey: "VersionOfLastRun") as? String
        appStatus = versionOfLastRun == nil ? .freshInstall : .upgrade

        if versionOfLastRun != currentVersion {
            let userDefaults = UserDefaults(suiteName: SCUtilities.getAppGroupId()) ?? UserDefaults.standard
            if UserDefaults.standard.double(forKey: "RefreshTokenExpiresInKey") != 0.0 {
                userDefaults.set(UserDefaults.standard.double(forKey: "RefreshTokenExpiresInKey"),
                                 forKey: "RefreshTokenExpiresInKey")
            }
            
            if UserDefaults.standard.double(forKey: "AccessTokenExpiresInKey") != 0.0 {
                userDefaults.set(UserDefaults.standard.double(forKey: "AccessTokenExpiresInKey"),
                                 forKey: "AccessTokenExpiresInKey")
            }
            
            if UserDefaults.standard.double(forKey: "AuthCreationTimeKey") != 0.0 {
                userDefaults.set(UserDefaults.standard.double(forKey: "AuthCreationTimeKey"),
                                 forKey: "AuthCreationTimeKey")
            }
            
            if UserDefaults.standard.bool(forKey: "ShouldRememberLoginKey") != false {
                userDefaults.set(UserDefaults.standard.bool(forKey: "ShouldRememberLoginKey"),
                                 forKey: "ShouldRememberLoginKey")
            }
            
            if let userId = UserDefaults.standard.string(forKey: GlobalConstants.userIDKey), userId != "-1" {
                userDefaults.set(userId, forKey: GlobalConstants.userIDKey)
            }
            
            if UserDefaults.standard.bool(forKey: GlobalConstants.isLoginApi) != false {
                userDefaults.set(UserDefaults.standard.bool(forKey: GlobalConstants.isLoginApi),
                                 forKey: GlobalConstants.isLoginApi)
            }
            
            if let info = UserDefaults.standard.value(forKey: GlobalConstants.logoutEventInfo) {
                userDefaults.set(info, forKey: GlobalConstants.logoutEventInfo)
            }
            
            if let oldRefreshToken = KeychainSwift().get("RefreshTokenKey") {
                KeychainSwift().delete("RefreshTokenKey")
                KeychainHelper().save(key: "RefreshTokenKey", value: oldRefreshToken)
            }
            
            if let oldAccessToken = KeychainSwift().get("AccessTokenKey") {
                KeychainHelper().save(key: "AccessTokenKey", value: oldAccessToken)
            }
            SCVersionHelper.clearDefaultsValuesAfterAddedToDefaultSuitName()
            
            #if targetEnvironment(simulator)
            if let accessToken = UserDefaults.standard.string(forKey: "AccessTokenKey") {
                userDefaults.set(accessToken, forKey: "AccessTokenKey")
            }
            
            if let refreshToken = UserDefaults.standard.string(forKey: "RefreshTokenKey") {
                userDefaults.set(refreshToken, forKey: "RefreshTokenKey")
            }
            #endif
        }
        UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")
        UserDefaults.standard.synchronize()
        completionHandler?(appStatus)
    }
    
    static private func clearDefaultsValuesAfterAddedToDefaultSuitName() {
        ["RefreshTokenExpiresInKey", "AccessTokenExpiresInKey", "AuthCreationTimeKey", "ShouldRememberLoginKey", "AccessTokenKey",
         "RefreshTokenKey", GlobalConstants.userIDKey, GlobalConstants.isLoginApi, GlobalConstants.logoutEventInfo].forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
