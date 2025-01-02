//
//  SCFeatureToggler.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 13.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

class SCFeatureToggler {
    static let shared = SCFeatureToggler()
    
    public var cityContentSharedWorker: SCCityContentSharedWorking?
    public var userContentSharedWorker: SCUserContentSharedWorking?
    
    // return true when the user is logged in and
    // the selected is the same like the city in the userprofile
    func isUserResidentOfSelectedCity() -> Bool {
        /*
        let userCity = self.userContentSharedWorker?.getUserData()?.profile.city
        
        guard let cityContentWorker = self.cityContentSharedWorker else {
            return false
        }
        
        let selectedCity = cityContentWorker.getCityContentData(for: cityContentWorker.getCityID())?.city.name
        
        return  ( userCity?.lowercased() == selectedCity?.lowercased() ) && SCAuth.shared.isUserLoggedIn()*/
        return true
    }
}
