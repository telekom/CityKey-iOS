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
//  SCAppContentSharedWorkerTests.swift
//  SmartCityTests
//
//  Created by Michael on 30.01.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCAppContentSharedWorkerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTriggerTermsUpdateSuccess() {
        
         let appContentSW = SCAppContentSharedWorker(requestFactory: MockRequestTermsSuccessData())

        XCTAssertFalse(appContentSW.areTermsLoading())

        appContentSW.triggerTermsUpdate(errorBlock: { (error) in
            XCTAssertNil(error)

            XCTAssertFalse(appContentSW.areTermsLoading())
            XCTAssertTrue(appContentSW.areTermsAvailable())

            XCTAssertEqual(appContentSW.getFAQLink(), "faqurl")
            XCTAssertEqual(appContentSW.getTermsAndConditions(), "termsurl")
            XCTAssertEqual(appContentSW.getLegalNotice(), "legalurl")
        })
    }

    func testTriggerTermsUpdateFailedWithEmptyStoredTerms() {
        
        let appContentSharedWorker = SCAppContentSharedWorker(requestFactory: MockRequestTermsFailedData())

        appContentSharedWorker.clearStoredTerms()

        XCTAssertFalse(appContentSharedWorker.areTermsLoading())
        XCTAssertFalse(appContentSharedWorker.isTermsLoadingFailed())

        appContentSharedWorker.triggerTermsUpdate(errorBlock: { (error) in
            XCTAssertNotNil(error)

            XCTAssertFalse(appContentSharedWorker.areTermsLoading())
            XCTAssertTrue(appContentSharedWorker.isTermsLoadingFailed())
            XCTAssertFalse(appContentSharedWorker.areTermsAvailable())

            XCTAssertNil(appContentSharedWorker.getFAQLink())
            XCTAssertNil(appContentSharedWorker.getTermsAndConditions())
            XCTAssertNil(appContentSharedWorker.getLegalNotice())
        })
    }

    func testTriggerTermsUpdateFailedWithEmptyFilledTerms() {
        
        let appContentSWSuccess = SCAppContentSharedWorker(requestFactory: MockRequestTermsSuccessData())
        let appContentSharedWorker = SCAppContentSharedWorker(requestFactory: MockRequestTermsFailedData())

        appContentSWSuccess.triggerTermsUpdate(errorBlock: { (error) in
            XCTAssertFalse(appContentSharedWorker.areTermsLoading())
            XCTAssertFalse(appContentSharedWorker.isTermsLoadingFailed())

            appContentSharedWorker.triggerTermsUpdate(errorBlock: { (error) in
                XCTAssertNotNil(error)

                XCTAssertFalse(appContentSharedWorker.areTermsLoading())
                XCTAssertTrue(appContentSharedWorker.isTermsLoadingFailed())
                XCTAssertTrue(appContentSharedWorker.areTermsAvailable())

                XCTAssertEqual(appContentSharedWorker.getFAQLink(), "faqurl")
                XCTAssertEqual(appContentSharedWorker.getTermsAndConditions(), "termsurl")
                XCTAssertEqual(appContentSharedWorker.getLegalNotice(), "legalurl")
            })
        })
    }

    private class MockRequestTermsSuccessData: SCRequestCreating, SCDataFetching {
        
        
        func createRequest() -> SCDataFetching {
            return MockRequestTermsSuccessData()
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
        "content" : [{

            "dataSecurity": {
              "adjustLink": "ADJUSTLINK",
              "dataUsage": "<h1>How we use your data?</h1>",
              "dataUsage2": "<h1>How we use your data?</h1>",
              "moEngageLink": "moeengaGELINK",
              "noticeText" : ""
            },
            "faq" : "faqurl",
            "legalNotice" : "legalurl",
            "termsAndConditions" : "termsurl",
        }]
    }
    """
    }

    private class MockRequestTermsFailedData: SCRequestCreating, SCDataFetching {
        
        
        func createRequest() -> SCDataFetching {
            return MockRequestTermsFailedData()
        }
        
        func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
            
            completion(.failure(SCRequestError.requestFailed(404, SCRequestErrorDetails(errorCode: "code", userMsg: "Email error text.", errorClientTrace: ""))))
        }
        
        func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
            
        }
        
        func cancel(){
        }

    }

}
