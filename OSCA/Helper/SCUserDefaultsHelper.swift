//
//  SCUserDefaultsHelper.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 17/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class SCUserDefaultsHelper: NSObject {
    
    static private var userDefaults: UserDefaults {
        return UserDefaults(suiteName: WidgetUtility().getAppGroupId()) ?? UserDefaults.standard
    }
    
    static func setPOICategoryID(poiCategoryID: Int) {
        UserDefaults.standard.set(poiCategoryID, forKey:GlobalConstants.poiCategoryIDKey)
    }
    
    static func getPOICategory() -> String? {
        return UserDefaults.standard.value(forKey:GlobalConstants.poiCategoryNameKey) as? String
    }
    
    static func getPOICategoryGroupIcon() -> String? {
        return UserDefaults.standard.value(forKey:GlobalConstants.poiCategoryGroupKey) as? String
    }
    
    static func setupCategoryIcon(_ url: String) -> UIImage{
        
        let activitiesIcon = "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_activities_2x.png"
        let familyIcon = "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_family_2x.png"
        let kidsIcon = "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_children_2x.png"
        let cultureIcon = "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_culture_2x.png"
        let lifeIcon = "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_life_2x.png"
        let natureIcon = "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_nature_2x.png"
        let otherIcon = "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_other_2x.png"
        let insidersIcon = "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/poi_insiders_2x.png"
        let mobilityIcon = "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/icon-category-mobility-2@2x.png"
        let sightsIcon = "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/icon-category-sights-2x.png"
        let recyclingIcon = "https://sol-preprod-img.obs.eu-de.otc.t-systems.com/img/icon-category-recycling@2x.png"
        
        switch url {
        case kidsIcon:
            return UIImage(named: "icon-category-children")!
            
        case cultureIcon:
            return UIImage(named: "icon-category-culture")!
            
        case activitiesIcon:
            return UIImage(named: "icon-category-activities")!
            
        case insidersIcon:
            return UIImage(named: "icon-category-insiders")!
            
        case familyIcon:
            return UIImage(named: "icon-category-family")!
            
        case lifeIcon:
            return UIImage(named: "icon-category-life")!
            
        case mobilityIcon:
            return UIImage(named: "icon-category-mobility")!
            
        case sightsIcon:
            return UIImage(named: "icon-category-sights")!

        case otherIcon:
            return UIImage(named: "icon-category-other")!

        case natureIcon:
            return UIImage(named: "icon-category-nature")!
        
        case recyclingIcon:
            return UIImage(named: "icon-category-recycling")!
    
        default:
            return UIImage(named: "icon-category-other")!
        }
    }
    
    static func setPOIListMap(isLoaded: Bool) {
        UserDefaults.standard.set(isLoaded, forKey:GlobalConstants.poiListMapLoaded)
    }
    
    static func getPOIListMap() -> Bool {
        return UserDefaults.standard.bool(forKey:GlobalConstants.poiListMapLoaded)
    }
    
    static func setCityStatus(status: Bool) {
        UserDefaults.standard.set(status, forKey: GlobalConstants.isCityActive)
    }
    
    static func getCityStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: GlobalConstants.isCityActive)
    }
    
    static func setDefaultCity(name: String, id: Int) {
        UserDefaults.standard.set(name, forKey: GlobalConstants.defaultCityName)
        UserDefaults.standard.set(id, forKey: GlobalConstants.defaultCityID)
    }
    
    static func getDefaultCityName() -> String {
        return UserDefaults.standard.string(forKey: GlobalConstants.defaultCityName) ?? ""
    }
    
    static func getDefaultCityId() -> Int {
        return  UserDefaults.standard.integer(forKey: GlobalConstants.defaultCityID)
    }
    
    static func setCurrentLocation(_ location: CLLocation) {
        //let locationData = NSKeyedArchiver.archivedData(withRootObject: location)
        if let locationData = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: false) {
            UserDefaults.standard.set(locationData, forKey: GlobalConstants.currentLocation)
        }

    }
    
    static func getCurrentLocation() -> CLLocation {

        if let loadedData = UserDefaults.standard.data(forKey: GlobalConstants.currentLocation){
            if let loadedLocation = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(loadedData) as? CLLocation {
                return loadedLocation
            }
        }
        return kSelectedCityLocation
    }
    
    static func setDefectLocationStatus(status: Bool) {
        UserDefaults.standard.set(status, forKey: GlobalConstants.isDefectLocationSet)
    }
    
    static func getDefectLocationStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: GlobalConstants.isDefectLocationSet)
    }
    
    static func setDefectLocation(_ location: CLLocation) {
        //let locationData = NSKeyedArchiver.archivedData(withRootObject: location)
        if let locationData = try? NSKeyedArchiver.archivedData(withRootObject: location, requiringSecureCoding: false) {
            UserDefaults.standard.set(locationData, forKey: GlobalConstants.defectLocation)
        }

    }
    
    static func getDefectLocation() -> CLLocation {
        if let loadedData = UserDefaults.standard.data(forKey: GlobalConstants.defectLocation){
                        
            if let loadedLocation = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(loadedData) as? CLLocation {
               return loadedLocation
            }
        }
        return kSelectedCityLocation
    }

    
    static func setUserID(_ userID: String) {
        if let userDefaults = UserDefaults(suiteName: WidgetUtility().getAppGroupId()) {
            userDefaults.set(userID, forKey:GlobalConstants.userIDKey)
        }
        UserDefaults.standard.set(userID, forKey:GlobalConstants.userIDKey)
    }
    
    static func getUserID() -> String? {
        if let userDefaults = UserDefaults(suiteName: WidgetUtility().getAppGroupId()) {
            return userDefaults.string(forKey: GlobalConstants.userIDKey)
        }
        return UserDefaults.standard.string(forKey: GlobalConstants.userIDKey)
    }
    
    // SMARTC-16772 iOS: Implement Dialog when user Unexpectedly logouts
    static func setLogOutEvent(_ isLoginApi : Bool) {
        userDefaults.set(isLoginApi, forKey: GlobalConstants.isLoginApi)
    }
    
    static func getLogOutEvent() -> Bool {
        return userDefaults.bool(forKey: GlobalConstants.isLoginApi)
    }
    
    static func setInfoOfLogOutEvent(logOutEventInfo: LogOutEventInfo) {
        let encodedData = try? PropertyListEncoder().encode(logOutEventInfo)
        userDefaults.set(encodedData, forKey:GlobalConstants.logoutEventInfo)
    }
    
    static func getInfoOfLogOutEvent() -> LogOutEventInfo? {
        if let data = userDefaults.value(forKey: GlobalConstants.logoutEventInfo) as? Data {
           return try? PropertyListDecoder().decode(LogOutEventInfo.self, from:data)
        }
       return nil
    }
    
    static func setSelectedCityID(id: Int) {
        UserDefaults.standard.set(id, forKey: GlobalConstants.selectedCityID)
    }
        
    static func getSelectedCityID() -> Int {
        return  UserDefaults.standard.integer(forKey: GlobalConstants.selectedCityID)
    }
    
    static func setIsSomeoneEverLoggedIn(status : Bool) {
        UserDefaults.standard.set(status, forKey: GlobalConstants.someoneEverloggedIn)
    }
        
    static func getIsSomeoneEverLoggedIn() -> Bool {
        return  UserDefaults.standard.bool(forKey: GlobalConstants.someoneEverloggedIn)
    }
    
    static func setRegistration(registration: SCModelRegistration) {
        let encodedData = try? PropertyListEncoder().encode(registration)
        UserDefaults.standard.set(encodedData, forKey:GlobalConstants.registrationKey)
    }
    
    static func getRegistration() -> SCModelRegistration? {
        if let data = UserDefaults.standard.value(forKey:GlobalConstants.registrationKey) as? Data {
           return try? PropertyListDecoder().decode(SCModelRegistration.self, from:data)
        }
       return nil
    }
}


/**
 *
 * LogOutEventInfo is the  model for collecting logout data
 *
 */
struct LogOutEventInfo : Codable {
    
    let userId : String
    let deviceId : String
    let keepMeLoggedIn: Bool
    
}
