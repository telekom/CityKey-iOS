/*
Created by telekom on 26.03.19.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation

typealias SCHTTPCode = Int

enum SCHttpStatus: String, Decodable {
    case ok1 = "OK"
    case ok2 = "200 OK"
    case ok3 = "200"
    case noContent = "204 NO_CONTENT"
    case unauthorized = "401 UNAUTHORIZED"
    case badRequest = "400 BAD_REQUEST"
    case internalServerError = "Internal Server Error"
    case unknown
    
    init(from decoder: Decoder) throws {
        let status = try decoder.singleValueContainer().decode(String.self)
        self = SCHttpStatus(rawValue: status) ?? .unknown
        if self == SCHttpStatus.unknown { debugPrint("Unknown status detected", status) }
    }
    
    func isOK() -> Bool {
        switch self {
        case .ok1, .ok2, .ok3:
            return true
        default:
            return false
        }
    }
}

struct HttpModelResponse<ContentModel: Decodable>: Decodable {
    let content: ContentModel?
}

struct SCHttpModelResponse<ContentModel: Decodable>: Decodable {
    let content: ContentModel
}

struct SCHttpModelBaseResponse: Decodable {
    let errors: [SCHttpErrorModel]?
}

struct SCHttpErrorModel: Decodable {
    let errorCode: String
    let userMsg: String
}

struct SCHttpErrorObjModel: Decodable {
    let field: String
    let userMsg: String
    
    func toModel() -> SCErrorObject {
        
        return SCErrorObject(field: field, userMsg: userMsg)
    }

}

struct SCErrorObject {
    let field: String
    let userMsg: String
}
