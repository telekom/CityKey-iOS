//
//  SCModelProfile.swift
//  SmartCity
//
//  Created by Michael on 04.12.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

/**
 * SCModelProfile is the data model for the user profile information
 *
 */

struct SCModelProfile : Codable{
    
    var accountId: Int
    var birthdate: Date?
    var email: String
    var postalCode: String
    var homeCityId: Int
    var cityName: String
    var dpnAccepted : Bool?
    var isCspUser : Bool?
}
