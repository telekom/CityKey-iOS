//
//  WidgetUtility.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 22/05/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import WidgetKit

struct WidgetUtility {
    func getAppGroupId() -> String {
        return "group.com.telekom.opensource.citykey"
    }
    
    func baseUrl(apiPath: String) -> String {
        var baseUrl: String = ""
        baseUrl = "https://mock.api.citykey"
        return baseUrl + apiPath
    }
    
    func getPrefferedLanguage() -> String {
        if let userDefaults = UserDefaults(suiteName: getAppGroupId()) {
            return userDefaults.string(forKey: "prefferedLanguage") ?? "en"
        }
        return "en"
    }
    
    func getUserId() -> String {
        if let userDefaults = UserDefaults(suiteName: WidgetUtility().getAppGroupId()) {
            return userDefaults.string(forKey: "userIDKey") ?? "-1"
        }
        return "-1"
    }
    
    func getKeychainAccessGroup() -> String {
        return "com.telekom.opensource.citykey.keychaingroup"
    }
    
    func reloadAllTimeLines() {
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            // Fallback on earlier versions
        }
    }
}
