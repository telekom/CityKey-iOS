/*
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
*///
//  SCUserContentSharedWorkerMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 13/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
@testable import OSCA

class SCUserContentSharedWorkerMock: SCUserContentSharedWorking {
    
    var userDataState =  SCWorkerDataState()
    var infoBoxDataState = SCWorkerDataState()
    var profileModel: SCModelProfile?
    func observeUserID(completion: @escaping (String?) -> Void) {
        
    }
    
    func getCityID() -> String? {
        return "city1"
    }
    
    func observeCityID(completion: @escaping (String?) -> Void) {
        
    }
    
    func isUserDataLoadingFailed() -> Bool {
        return false
    }
    
    func getUserID() -> String? {
        return "id1"
    }
    
    func isUserDataAvailable() -> Bool {
        return true
    }
    
    func isUserDataLoading() -> Bool {
        return false
    }
    
    func getUserData() -> SCModelUserData? {
        let profile = SCModelProfile(accountId : 2, birthdate: Date(timeIntervalSince1970: TimeInterval(1561780587)), email: "test@tester.de", postalCode: "63739", homeCityId: 10, cityName: "Teststadt", dpnAccepted: true)

        return SCModelUserData(userID: "2", cityID: "10", profile: profileModel ?? profile)
    }
    
    func triggerUserDataUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        errorBlock(nil)
    }
    
    func isInfoBoxDataAvailable() -> Bool {
        return true
    }
    
    func isInfoBoxDataLoading() -> Bool {
        return false
    }
    
    func isInfoBoxDataLoadingFailed() -> Bool {
        return false
    }
    
    func getInfoBoxData() -> [SCModelInfoBoxItem]? {
        return [SCModelInfoBoxItem(userInfoId: 1, messageId: 1, description: "Info1", details: "More Details", headline: "Messahe Headline", isRead: false,  creationDate: dateFromString(dateString: "2019-08-01 00-00-00")!, category: SCModelInfoBoxItemCategory(categoryIcon: "icon.png", categoryName: "category1"), buttonText: "ok", buttonAction: "", attachments: [])]
    }

    
    func triggerInfoBoxDataUpdate(errorBlock: @escaping (SCWorkerError?)->()){
        errorBlock(nil)
    }

    func markInfoBoxItem(id : Int, read : Bool) {
        
    }
    
    func removeInfoBoxItem(id : Int){
        
    }
    
    func clearData(){
        
    }
    
}
