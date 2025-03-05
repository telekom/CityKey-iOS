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
//  SCAppContentWorkerMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

@testable import OSCA

class SCAppContentWorkerMock: SCAppContentSharedWorking {
    var acceptDataPrivacyNoticeChangeError: SCWorkerError?
    var acceptDataPrivacyNoticeChangeCount: Int?
    
    init(acceptDataPrivacyNoticeChangeError: SCWorkerError? = nil, count: Int? = 0) {
        self.acceptDataPrivacyNoticeChangeError = acceptDataPrivacyNoticeChangeError
        self.acceptDataPrivacyNoticeChangeCount = count
    }

    func acceptDataPrivacyNoticeChange(completion: @escaping (SCWorkerError?, Int?) -> Void) {
        completion(acceptDataPrivacyNoticeChangeError,
                   acceptDataPrivacyNoticeChangeCount)
    }
    
    func isNearestCityAvailable() -> Bool {
        return false
    }
    
    func updateNearestCity(cityId: Int) {
        
    }
    
    func storedNearestCity() -> Int {
        return 0
    }
    
    func isDistanceToNearestLocationAvailable() -> Bool {
        return false
    }
    
    func updateDistanceToNearestLocation(distance: Double) {
        
    }
    
    func storedDistanceToNearestLocation() -> Double? {
        return 0.0
    }
    

    var termsDataState =  SCWorkerDataState()

    var firstTimeUsageFinished: Bool = true
    
    var switchLocationToolTipShouldBeShown: Bool = true

    var trackingPermissionFinished: Bool = true
    
    func getDataSecurity() -> SCModelTermsDataSecurity? {
        return nil
    }

    var isToolTipShown: Bool = true
    
    var privacyOptOutMoEngage: Bool = true
    
    var privacyOptOutAdjust: Bool = true
     
    var isCityActive: Bool = true

    func getDataPrivacyLink() -> String? {
        return nil
    }
    
    func observePrivacySettings(completion: @escaping (Bool, Bool) -> Void) {
        
    }
    
    func getFAQLink() -> String? {
        return nil
    }
    
    func getLegalNotice() -> String? {
        return nil
    }
    
    func getTermsAndConditions() -> String? {
        return nil
    }
    
    func triggerTermsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        
    }
    

}
