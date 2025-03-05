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
//  SCUserContentSharedWorkerTests.swift
//  SmartCityTests
//
//  Created by Robert Swoboda - Telekom on 28.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCUserContentSharedWorkerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTriggerAndGetUserData() {
        
        let userContentSharedWorker = SCUserContentSharedWorker(requestFactory: MockRequestUserData())
        
        XCTAssertFalse(userContentSharedWorker.isUserDataLoading())

        userContentSharedWorker.triggerUserDataUpdate { (error) in
            XCTAssertNil(error)
    
            XCTAssertFalse(userContentSharedWorker.isUserDataLoading())
            XCTAssertTrue(userContentSharedWorker.isUserDataAvailable())

            let userData = userContentSharedWorker.getUserData()
            
            XCTAssertEqual(userData?.userID, "158")
            XCTAssertEqual(userData?.profile.email, "gexow13078@aprimail.com")
            XCTAssertEqual(userData?.profile.postalCode, "40789")
        }
    }

    func testUserIDObserver() {
        
        let userContentSharedWorker = SCUserContentSharedWorker(requestFactory: MockRequestUserData())
        
        let expectation = self.expectation(description: "Oberver")

        XCTAssertFalse(userContentSharedWorker.isUserDataAvailable())

        userContentSharedWorker.observeUserID(completion: {
            (userID) in
            
            XCTAssertEqual(userID, "158")
            expectation.fulfill()
        })
        
        userContentSharedWorker.triggerUserDataUpdate { (error) in
            XCTAssertNil(error)
    
            XCTAssertTrue(userContentSharedWorker.isUserDataAvailable())
        }
        
        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)
    }
    

    func testClearData() {
        
        let userContentSharedWorker = SCUserContentSharedWorker(requestFactory: MockRequestUserData())
        
        let expectationUserData = self.expectation(description: "WaitForUserData")
        let expectationInfoBox = self.expectation(description: "WaitForInBox")

        userContentSharedWorker.triggerUserDataUpdate { (error) in
            expectationUserData.fulfill()
        }
        
        userContentSharedWorker.triggerInfoBoxDataUpdate{ (error) in
            expectationInfoBox.fulfill()
        }

        // Wait for the expectation to be fullfilled, or time out
        // after 5 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 5, handler: nil)

        let expectationObserve = self.expectation(description: "Observe")

        userContentSharedWorker.observeUserID(completion: {
            (userID) in
            
            XCTAssertNil(userID)
            expectationObserve.fulfill()
        })

        userContentSharedWorker.clearData()
        
        XCTAssertNil(userContentSharedWorker.getInfoBoxData())
        XCTAssertNil(userContentSharedWorker.getUserData())
        
        waitForExpectations(timeout: 5, handler: nil)

    }
    
    func testTriggerAndGetInfoBoxData() {

        let userContentSharedWorker = SCUserContentSharedWorker(requestFactory: MockRequestInfoBoxData())
 
        XCTAssertFalse(userContentSharedWorker.isInfoBoxDataLoading())

        userContentSharedWorker.triggerInfoBoxDataUpdate{ (error) in
            XCTAssertNil(error)

            XCTAssertFalse(userContentSharedWorker.isInfoBoxDataLoading())
            XCTAssertTrue(userContentSharedWorker.isInfoBoxDataAvailable())

            let infoboxItems = userContentSharedWorker.getInfoBoxData()!
            XCTAssertEqual(infoboxItems.count, 1)

            let item = infoboxItems[0]
            XCTAssertEqual(item.category.categoryIcon, "/img/message-icon.png")
            XCTAssertEqual(item.category.categoryName, "Willkommen")
            XCTAssertEqual(item.creationDate, dateFromString(dateString: "2020-08-18 16:40:17"))
            XCTAssertEqual(item.headline, "Willkommen zur Citykey App! Schön, dass sie dabei sind.")
            XCTAssertEqual(item.details, "Ob sie Terminbestätigungen von benutzten Bürgerservices erwarten oder über zukünftige Funktionen der Citykey App informiert werden wollen: hier erfahren Sie es zuerst")
            XCTAssertEqual(item.description, "Wir halten Sie in unserer »Mailbox« über die wichtigen Dinge auf dem Laufenden.")
            XCTAssertEqual(item.userInfoId, 20)
            XCTAssertEqual(item.isRead, false)
            XCTAssertEqual(item.buttonAction, "//test")
            XCTAssertEqual(item.buttonText, "test")
            XCTAssertEqual(item.attachments.first!.attachmentLink, "https://cdn.pixabay.com/photo/2018/01/14/23/12/nature-3082832_960_720.jpg")
            XCTAssertEqual(item.attachments.first!.attachmentText, "Beauty of the Nature")
        }
    }
}

private class MockRequestUserData: SCRequestCreating, SCDataFetching {
    
    
    func createRequest() -> SCDataFetching {
        return MockRequestUserData()
    }
    
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        
        let mockData = userJson.data(using: .utf8)!
        completion(.success(mockData))
    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel(){
    }

    // MARK: - WARNING!
    /*
     Beware: in mock jsons using the """ text """ format,
    we need to DOUBLE ESCAPE and special charaters, e.g.:
     \\n instead of \m
     and
     \\" insteand if \"
    */
    // MARK: -
    private let userJson = """
{
    "content": {
        "accountId": 158,
        "dateOfBirth": "2010-12-01",
        "email": "gexow13078@aprimail.com",
        "postalCode": "40789",
        "homeCityId": 10,
        "cityName": "Teststadt",
        "dpnAccepted": true
    }
}
"""
}

private class MockRequestInfoBoxData: SCRequestCreating, SCDataFetching {
    
    
    func createRequest() -> SCDataFetching {
        return MockRequestInfoBoxData()
    }
    
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        
        let mockData = userJson.data(using: .utf8)!
        completion(.success(mockData))
    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel(){
    }
    
    // MARK: - WARNING!
    /*
     Beware: in mock jsons using the """ text """ format,
     we need to DOUBLE ESCAPE and special charaters, e.g.:
     \\n instead of \m
     and
     \\" insteand if \"
     */
    // MARK: -
    private let userJson = """

{
    "content": [
        {
            "userInfoId": 20,
            "messageId": 123,
            "description": "Wir halten Sie in unserer »Mailbox« über die wichtigen Dinge auf dem Laufenden.",
            "details": "Ob sie Terminbestätigungen von benutzten Bürgerservices erwarten oder über zukünftige Funktionen der Citykey App informiert werden wollen: hier erfahren Sie es zuerst",
            "headline": "Willkommen zur Citykey App! Schön, dass sie dabei sind.",
            "buttonAction": "//test",
            "buttonText": "test",
            "isRead": false,
            "creationDate": "2020-08-18 16:40:17",
            "category": {
                "categoryIcon": "/img/message-icon.png",
                "categoryName": "Willkommen"
            },
            "attachments": [{
                "attachmentLink": "https://cdn.pixabay.com/photo/2018/01/14/23/12/nature-3082832_960_720.jpg",
                "attachmentText": "Beauty of the Nature"
            }]
        }
    ]
}
"""
}

