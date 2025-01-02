//
//  SCUserDefaultsHelper+Extension.swift
//  OSCA
//
//  Created by Bhaskar N S on 19/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
