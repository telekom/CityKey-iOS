//
//  SCHttpModelRegistrationResult.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 25.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCHttpModelRegistrationResponseContent: Decodable {
    let result: SCHttpModelRegistrationResult
}

struct SCHttpModelRegistrationResult: Decodable {
    let isSuccessful: Bool
    let message: SCHttpModelRegistrationMessage?
    let monheimPassException: SCHttpModelMonheimPassException?
}

struct SCHttpModelRegistrationMessage: Decodable { //proposal: rename to SCHttpModelRegistrationError
    let errorCode: String?
    let message: String?
}

struct SCHttpModelMonheimPassException: Decodable {
    let code: String?
    let message: String
}
