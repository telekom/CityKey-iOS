//
//  SCModelUserData.swift
//  SmartCity
//
//  Created by Michael on 10.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

struct SCModelUserData {
    let userID: String
    let cityID: String
    let profile: SCModelProfile
}

struct SCHttpModelUserData: Decodable {
    let accountId: Int
    let dateOfBirth: String?
    let email: String
    let postalCode: String
    var homeCityId: Int
    var cityName: String
    var dpnAccepted : Bool?
    var isCspUser : Bool?

    func toModel() -> SCModelUserData {
        
        var birthdate : Date? = nil
        if let dateOfBirth = dateOfBirth {
            birthdate = birthdayDateFromString(dateString: dateOfBirth)
        }
        
        let profile = SCModelProfile(accountId: accountId, birthdate: birthdate, email: email, postalCode: postalCode, homeCityId: homeCityId, cityName: cityName, dpnAccepted: dpnAccepted, isCspUser: isCspUser)
        
        return SCModelUserData(userID: String(accountId), cityID: String(homeCityId),
                               profile: profile)
    }

}
