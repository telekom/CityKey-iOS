//
//  SCLoginWorkerTests.swift
//  SmartCityTests
//
//  Created by Michael on 29.07.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCLoginWorkerTests: XCTestCase {

    func testParsingSuccessResult() {
        
        SCAuth.shared.worker = SCAuthorizationWorker(requestFactory: MockAuthRequest(success: true))
        
        let worker = SCLoginWorker(requestFactory: MockRequest(), authProvider: SCAuth.shared)
        
        let loginSuccessfulExpectation = expectation(description: "login successful")
            
        worker.login(email: "correct@email.com", password: "password correct", remember: false) { (loginError) in
            XCTAssertEqual(SCAuth.shared.getRefreshToken(), "mocked_refresh_token")
            XCTAssertTrue(SCAuth.shared.isUserLoggedIn())
            
            loginSuccessfulExpectation.fulfill()
         }
        
        wait(for: [loginSuccessfulExpectation], timeout: 1)

    }
    
    func testParsingErrorResult() {
        
        SCAuth.shared.worker = SCAuthorizationWorker(requestFactory: MockAuthRequest(success: false))
        
        let worker = SCLoginWorker(requestFactory: MockRequest(), authProvider: SCAuth.shared)
        
        let loginSuccessfulExpectation = expectation(description: "login successful")
        
        worker.login(email: "wrong@email.com", password: "password correct", remember: false) { (error) in
            
            XCTAssertNotNil(error)
            
            switch error! {
            case .fetchFailed(let details):
                XCTAssertEqual(details.errorCode!, "user.active")
            default :
                XCTAssert(false)
            }

            XCTAssertNil(SCAuth.shared.getRefreshToken())

            loginSuccessfulExpectation.fulfill()
        }
        
        wait(for: [loginSuccessfulExpectation], timeout: 1)

    }
    
    func testLogout() {
        let auth: SCAuth & SCAuthTokenProviding = SCAuth.shared
        auth.worker = SCAuthorizationWorker(requestFactory: MockAuthRequest(success: true))
        
        let worker = SCLoginWorker(requestFactory: MockRequest(), authProvider: auth)
        let logoutSuccessfulExpectation = expectation(description: "logout successful")
        
        worker.login(email: "correct@email.com", password: "password correct", remember: false) { (loginError) in
            XCTAssertEqual(SCAuth.shared.getRefreshToken(), "mocked_refresh_token")
            XCTAssertTrue(SCAuth.shared.isUserLoggedIn())
        }
        worker.logout {
            XCTAssertNil(auth.getRefreshToken())
            logoutSuccessfulExpectation.fulfill()
        }
        
        wait(for: [logoutSuccessfulExpectation], timeout: 3)
    }
    
    func testClearLogoutResason() {
        let auth: SCAuth & SCAuthTokenProviding = SCAuth.shared
        auth.worker = SCAuthorizationWorker(requestFactory: MockAuthRequest(success: true))
        
        let worker = SCLoginWorker(requestFactory: MockRequest(), authProvider: SCAuth.shared)
        worker.clearLogoutResason()
        XCTAssertNil(auth.logoutReason())
    }
}

private class MockRequest: SCRequestCreating, SCDataFetching {
    
    
    func createRequest() -> SCDataFetching {
        return MockRequest()
    }
    
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        
     }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel(){
    }

}


fileprivate class MockAuthRequest: SCRequestCreating, SCDataFetching {
    
    public let success: Bool
    
    private let loginJson = """
        {
        "content": {
            "access_token": "mocked_access_token",
            "token_type": "bearer",
            "refresh_token": "mocked_refresh_token",
            "expires_in": 299,
            "scope": "email openid profile",
            "refresh_expires_in": 600
        }
        }
    """
    private let loginFailedJson = """
    {
        "error": {
            "errorCode": "user.active",
            "userMsg": "Invalid user credentials. Please try again."
        }
    }
    """
    
    let logoutJson = ""
    let refreshedJson = ""
    
    init(success: Bool) {
        self.success = success
    }
    
    func createRequest() -> SCDataFetching {
        return MockAuthRequest(success: self.success)
    }
    
    func fetchData(from url: URL, method: String, body: Data?, needsAuth: Bool, completion: @escaping ((SCRequestResult) -> ())) {
        
        var jsonString: String = ""
        
        if url.absoluteString.contains("POST_Login") {
            jsonString = self.success ? loginJson : loginFailedJson
        } else {
            jsonString = "error"
        }
        
        let mockData = jsonString.data(using: .utf8)!
        
        self.success ? completion(.success(mockData)) : completion(.failure(SCRequestError.unauthorized(SCRequestErrorDetails(errorCode: "user.active", userMsg: "Invalid user credentials. Please try again.", errorClientTrace: ""))))
   }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel(){
    }

}
