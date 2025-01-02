//
//  SCModelRegistration.swift
//  SmartCity
//
//  Created by Michael on 30.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

struct SCModelRegistration : Codable{
    let eMail: String
    let pwd: String
    let language: String
    let birthdate: String?
    let postalCode: String
    let privacyAccepted: Bool
}
