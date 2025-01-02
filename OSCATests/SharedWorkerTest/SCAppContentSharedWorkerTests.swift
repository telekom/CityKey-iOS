//
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
