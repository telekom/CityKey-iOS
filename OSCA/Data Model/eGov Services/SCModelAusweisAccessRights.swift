/*
Created by Bharat Jagtap on 12/03/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation

struct SCModelAusweisAccessRights  {
    
    let msg : String
    let error : String?
    let transactionInfo : String?
    let canAllowed : Bool?
    
    // values from 'aux'
    let ageVerificationDate : String?
    let requiredAge : String?
    let validityDate : String?
    let communityId : String?
    
    // values from 'chat'
    let effective : [String]
    let chatOptional : [String]
    let chatRequired : [String]

//    init(msg: String, error: String?, transactionInfo: String?, canAllowed: Bool?, ageVerificationDate: String?, requiredAge: String?, validityDate: String?, communityId: String?, effective: String, chatOptional: String, chatRequired: String) {
//
//        self.msg = msg
//        self.error = error
//        self.transactionInfo = transactionInfo
//        self.canAllowed = canAllowed
//        self.ageVerificationDate = ageVerificationDate
//        self.requiredAge = requiredAge
//        self.validityDate = validityDate
//        self.communityId = communityId
//        self.effective = effective
//        self.chatOptional = chatOptional
//        self.chatRequired = chatRequired
//    }
    
}

struct SCHTTPModelAusweisAccessRights: Decodable {
    
    let msg : String
    let error : String?
    
    let aux: Aux?
    struct Aux: Decodable {
        let ageVerificationDate, requiredAge, validityDate, communityId: String?
    }
    
    let chat: Chat
    struct Chat: Decodable {
        let effective, chatOptional, chatRequired: [String]
        enum CodingKeys: String, CodingKey {
            case effective = "effective"
            case chatOptional = "optional"
            case chatRequired = "required"
        }
    }
    
    let transactionInfo: String?
    let canAllowed: Bool?
    
    
    func toModel() -> SCModelAusweisAccessRights {
        
       // return SCModelAusweisAccessRights(msg: self.msg, error: self.error, transactionInfo: self.transactionInfo, canAllowed: self.canAllowed, ageVerificationDate: self.aux?.ageVerificationDate, requiredAge: self.aux?.requiredAge, validityDate: self.aux?.validityDate, communityId: self.aux?.communityId, effective: self.chat.effective, chatOptional: self.chat.chatOptional, chatRequired: self.chat.chatRequired)
        
        
        return SCModelAusweisAccessRights(msg: self.msg,
                                          error: self.error,
                                          transactionInfo: self.transactionInfo,
                                          canAllowed: self.canAllowed,
                                          ageVerificationDate: self.aux?.ageVerificationDate,
                                          requiredAge: self.aux?.requiredAge,
                                          validityDate: self.aux?.validityDate,
                                          communityId: self.aux?.communityId,
                                          effective: self.chat.effective.map { "egov_sdk_\($0)".localized() },
                                          chatOptional: self.chat.chatOptional,
                                          chatRequired: self.chat.chatRequired)
         
    }
}
