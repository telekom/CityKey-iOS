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
//  SCProfileTests.swift
//  SmartCityTests
//
//  Created by Robert Swoboda - Telekom on 03.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCProfileTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // temporarily disabled due to architecture change to MVP -> SCProfilePresenter
    /*
    func testLogout() {
        
        let logoutSuccessfulExpectation = expectation(description: "logout successful")
        
        let logic = SCProfileLogic(service: SCProfileService(requestFactory: MockDataFetcher()), authProvider: SCAuth.shared)
        
        // will be more reasonable as soon as error handling is fully implemented
        logic.logout() {
            logoutSuccessfulExpectation.fulfill()
        }
        
        wait(for: [logoutSuccessfulExpectation], timeout: 1)
    }
        */
    
    /*
    func testFetchProfile() {
        let service = SCProfileService(requestFactory: MockDataFetcher())
        let profileLogic = SCProfileLogic(service: service, authProvider: MockAuthProvider())
        
        let profileFetchedExpectation = expectation(description: "profile fetched and decoded")
        
        profileLogic.fetchProfile { success in
            XCTAssertEqual(profileLogic.firstName(), "Chuck")
            XCTAssertEqual(profileLogic.city(), "Darmstadt")
            profileFetchedExpectation.fulfill()
        }
        wait(for: [profileFetchedExpectation], timeout: 1)
    }
 */
}

fileprivate class MockDataFetcher: SCDataFetching, SCRequestCreating {

    let profileJson = """
        {"status":"OK",
        "content":{"password":"TOP_SECRET","dayOfBirthday":"2001-12-15","username":"Chucky","firstName":"Chuck","credit":null,"id":57,"userStatus":null,"city":"Darmstadt","email":"chuck@norris.de",
        "role":"ROLE_USER","lastName":"Norris","street":"Missing in1","postalCode":null,"userImage":null,"userImageUUID":"18beed6f-2f22-11e9-be41-f7723f0cd8d6",
        "favoritesCollection":{"citizenService":[{"ranking":1,"user_id":57,"serviceId":48},{"ranking":2,"user_id":57,"serviceId":5},{"ranking":2,"user_id":57,"serviceId":47},
        {"ranking":4,"user_id":57,"serviceId":4},{"ranking":6,"user_id":57,"serviceId":2},{"ranking":7,"user_id":57,"serviceId":53},{"ranking":9,"user_id":57,"serviceId":21}],
        "marketplace":[{"ranking":1,"user_id":57,"marketplaceId":77},{"ranking":3,"user_id":57,"marketplaceId":14},{"ranking":6,"user_id":57,"marketplaceId":18},
        {"ranking":9,"user_id":57,"marketplaceId":7},{"ranking":12,"user_id":57,"marketplaceId":17}],"cityContent":[]},"paymentCollection":[],
        "userInfoBoxCollection":[{"teaser":"Transfer confirmation","details":"The transfer confirmation for your move is ready to be found in your document safe.",
        "userInfoId":109,"creationDate":"2019-02-09T23:00:00.000+0000","read":true,"description":"Sample description","icon":"/img/Umzug.png","typ":"INFO"}]},
        "message":"just mock data"}
        """
    
    let logoutJson = """
    """
    
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {

        let mockData = profileJson.data(using: .utf8)!
        completion(.success(mockData))
    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func createRequest() -> SCDataFetching {
        return MockDataFetcher()
    }
    
    func cancel(){
    }

}

fileprivate class MockAuthProvider: SCLogoutAuthProviding {
    func isUserLoggedIn() -> Bool {
        return true
    }
    func logout(logoutReason: SCLogoutReason, completion: @escaping () -> ()) {
        completion()
    }
}
