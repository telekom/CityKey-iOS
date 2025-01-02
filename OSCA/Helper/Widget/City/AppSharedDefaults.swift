//
//  CityKey.swift
//  OSCA
//
//  Created by A200111500 on 01/05/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import SwiftUI
import WidgetKit

struct AppSharedDefaults {

    func storeCityId(cityId: String) {
        
        if let userDefaults = UserDefaults(suiteName: SCUtilities.getAppGroupId()) {
            userDefaults.set(cityId, forKey: UserDefaultKeys.cityKey)
        }
        savePreferredLanguage()
    }

    func storeCityNews(cityNews: Data?) {
        if let userDefaults = UserDefaults(suiteName: SCUtilities.getAppGroupId()) {
            userDefaults.set(cityNews, forKey: UserDefaultKeys.cityNews)
        }
    }
    
    private func savePreferredLanguage() {
        if let userDefaults = UserDefaults(suiteName: SCUtilities.getAppGroupId()) {
            userDefaults.set(SCUtilities.preferredContentLanguage(), forKey:GlobalConstants.prefferedLanguage)
        }
    }

    func saveNewsError(message: String?) {
        if let userDefaults = UserDefaults(suiteName: SCUtilities.getAppGroupId()) {
            userDefaults.set(message, forKey: UserDefaultKeys.newsError)
        }
    }
}

