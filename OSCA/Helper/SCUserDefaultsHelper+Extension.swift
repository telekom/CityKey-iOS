/*
Created by Bhaskar N S on 19/08/22.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import CoreLocation

protocol UserDefaultsHelping {
	func setProfile(profile: SCModelProfile)
	func getProfile() -> SCModelProfile?
	func setPOIInfo(poiInfo: [POIInfo])
	func getPOIInfo() -> [POIInfo]?
	func setSelectedPOICategory(poiCategory: SCModelPOICategoryList)
	func getSelectedPOICategory() -> SCModelPOICategoryList?
	func getPOICategoryID() -> Int?
	func getSelectedCityID()  -> Int
	func getCurrentLocation() -> CLLocation
	func setPOICategoryID(poiCategoryID: Int)
	func getPOICategory() -> String?
	func setPOICategory(poiCategory: String)
	func setPOICategoryGroupIcon(poiCategory: String)
	func setSelectedCityID(id: Int)
}

class UserdefaultHelper: UserDefaultsHelping {
	func setProfile(profile: SCModelProfile) {
		let encodedData = try? PropertyListEncoder().encode(profile)
		UserDefaults.standard.set(encodedData, forKey:GlobalConstants.profileKey)
	}
	
	func getProfile() -> SCModelProfile? {
		if let data = UserDefaults.standard.value(forKey:GlobalConstants.profileKey) as? Data {
		   return try? PropertyListDecoder().decode(SCModelProfile.self, from:data)
		}
	   return nil
	}
	
	func setPOIInfo(poiInfo: [POIInfo]) {
		let encodedData = try? PropertyListEncoder().encode(poiInfo)
		UserDefaults.standard.set(encodedData, forKey:GlobalConstants.poiKey)
	}
	
	func getPOIInfo() -> [POIInfo]? {
		if let data = UserDefaults.standard.value(forKey:GlobalConstants.poiKey) as? Data {
		   return try? PropertyListDecoder().decode([POIInfo].self, from:data)
		}
	   return nil
	}
	
	func setSelectedPOICategory(poiCategory: SCModelPOICategoryList) {
		let encodedData = try? PropertyListEncoder().encode(poiCategory)
		UserDefaults.standard.set(encodedData, forKey:GlobalConstants.poiCategoryKey)
	}
	
	func getSelectedPOICategory() -> SCModelPOICategoryList? {
		if let data = UserDefaults.standard.value(forKey:GlobalConstants.poiCategoryKey) as? Data {
		   return try? PropertyListDecoder().decode(SCModelPOICategoryList.self, from:data)
		}
	   return nil
	}
	
	func getPOICategoryID() -> Int? {
		return UserDefaults.standard.integer(forKey: GlobalConstants.poiCategoryIDKey)
	}
	
	func getSelectedCityID() -> Int {
		return  UserDefaults.standard.integer(forKey: GlobalConstants.selectedCityID)
	}
	
	func getCurrentLocation() -> CLLocation {

		if let loadedData = UserDefaults.standard.data(forKey: GlobalConstants.currentLocation){
			if let loadedLocation = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(loadedData) as? CLLocation {
				return loadedLocation
			}
		}
		return kSelectedCityLocation
	}
	
	func setPOICategoryID(poiCategoryID: Int) {
		UserDefaults.standard.set(poiCategoryID, forKey:GlobalConstants.poiCategoryIDKey)
	}
	
	func getPOICategory() -> String? {
		return UserDefaults.standard.value(forKey:GlobalConstants.poiCategoryNameKey) as? String
	}
	
	func setPOICategory(poiCategory: String) {
		UserDefaults.standard.set(poiCategory, forKey:GlobalConstants.poiCategoryNameKey)
	}
	
	func setPOICategoryGroupIcon(poiCategory: String) {
		UserDefaults.standard.set(poiCategory, forKey:GlobalConstants.poiCategoryGroupKey)
	}
	
	func setSelectedCityID(id: Int) {
		UserDefaults.standard.set(id, forKey: GlobalConstants.selectedCityID)
	}
}

extension SCUserDefaultsHelper {
    
    static func setProfile(profile: SCModelProfile) {
        let encodedData = try? PropertyListEncoder().encode(profile)
        UserDefaults.standard.set(encodedData, forKey:GlobalConstants.profileKey)
    }
    
    static func getProfile() -> SCModelProfile? {
        if let data = UserDefaults.standard.value(forKey:GlobalConstants.profileKey) as? Data {
           return try? PropertyListDecoder().decode(SCModelProfile.self, from:data)
        }
       return nil
    }
    
    static func clearProfileData() {
        if let data = UserDefaults.standard.value(forKey:GlobalConstants.profileKey) as? Data {
            UserDefaults.standard.removeObject(forKey: GlobalConstants.profileKey)
        }
    }
}
