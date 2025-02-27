/*
Created by Robert Swoboda - Telekom on 03.04.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Robert Swoboda
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
