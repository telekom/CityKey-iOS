//
//  SCModelAuthorization.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 03.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelAuthorization {
    let accessToken: String
    let accessTokenExpiresIn: TimeInterval
    let refreshToken: String
    let birthDate: Date
    let refreshTokenExpiresIn: TimeInterval
    
    // SMARTC-18143 iOS : Implement Logging for login/logout functionality
    func description() -> String {
        return ("acessToken: \(accessToken), accessTokenExpiresIn: \(accessTokenExpiresIn), refreshToken: \(refreshToken), refreshTokenExpiresIn: \(refreshTokenExpiresIn)")
    }
}

struct SCHttpModelAuthorization: Decodable {
    let access_token: String
    let token_type: String
    let refresh_token: String
    let expires_in: Int // seconds
    let refresh_expires_in: Int //seconds
    let scope: String
    
    enum CodingKeys: String, CodingKey {
        case access_token
        case token_type
        case refresh_token
        case expires_in
        case refresh_expires_in
        case scope
    }
    
    func toModel() -> SCModelAuthorization {
        return SCModelAuthorization(accessToken: access_token,
                                    accessTokenExpiresIn: TimeInterval(expires_in),
                                    refreshToken: refresh_token,
                                    birthDate: Date(),
                                    refreshTokenExpiresIn: TimeInterval(refresh_expires_in))
    }
}
// Example Login response
/*
 "access_token":    "ptGhTzFnSLCtyYe2SSULsc539YrNGcg",
 "token_type": "bearer",
 "refresh_token": "Pvp20qb_OE5K8fZJVEgPHErbyf-Y4",
 "expires_in": 299,
 "scope": "email openid profile",
 "refresh_expires_in": 1800,
 "id_token": "pNimuWNsN4yryx5SLKMH-RNlVmyLXLA",
 "not-before-policy": 0,
 "session_state": "5d027b17-c4c8-48cb-9af4-7f49403c979e"
 */
