//
//  SCAuthTests.swift
//  SmartCityTests
//
//  Created by Robert Swoboda - Telekom on 18.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCAuthTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        SCAuth.shared.removeAuthorization()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        SCAuth.shared.removeAuthorization()
    }

    func testLoginWithCorrectInput() {
        SCAuth.shared.worker = SCAuthorizationWorker(requestFactory: MockAuthRequest(success: true))

        XCTAssertNil(SCAuth.shared.getRefreshToken())
        XCTAssertFalse(SCAuth.shared.isUserLoggedIn())
        
        let loginSuccessfulExpectation = expectation(description: "login successful")
        
        SCAuth.shared.login(name: "Username correct", password: "Password correct", remember: true) { (loginError) in
            XCTAssertNil(loginError)
            
            XCTAssertEqual(SCAuth.shared.getRefreshToken(), "mocked_refresh_token")
            XCTAssertTrue(SCAuth.shared.isUserLoggedIn())
            
            SCAuth.shared.fetchAccessToken() { (accessToken, userID, error)  in
                XCTAssertEqual(accessToken, "mocked_access_token")
                
                loginSuccessfulExpectation.fulfill()
            }
        }
        
        wait(for: [loginSuccessfulExpectation], timeout: 1)
    }
    
    func testLoginWithWrongInput() {
        SCAuth.shared.worker = SCAuthorizationWorker(requestFactory: MockAuthRequest(success: false))

        XCTAssertNil(SCAuth.shared.getRefreshToken())
        XCTAssertFalse(SCAuth.shared.isUserLoggedIn())
        
        let loginFailureExpectation = expectation(description: "login failes")
        
        SCAuth.shared.login(name: "Username wrong", password: "password wrong", remember: false) { (loginError) in
            
            // TODO: change this to checking on correct error message, something broke
            XCTAssertNotNil(loginError)

            XCTAssertNil(SCAuth.shared.getRefreshToken())
            
            loginFailureExpectation.fulfill()
        }
        
        wait(for: [loginFailureExpectation], timeout: 1)
    }
    
    func testLogout() {
        SCAuth.shared.worker = SCAuthorizationWorker(requestFactory: MockAuthRequest(success: true))
        
        XCTAssertNil(SCAuth.shared.getRefreshToken())
        XCTAssertFalse(SCAuth.shared.isUserLoggedIn())
        
        let logoutSuccessfulExpectation = expectation(description: "logout successful")
        
        // first we login
        SCAuth.shared.login(name: "Username correct", password: "Password correct", remember: true) { (loginError) in
            XCTAssertNil(loginError)
            
            XCTAssertEqual(SCAuth.shared.getRefreshToken(), "mocked_refresh_token")
            XCTAssertTrue(SCAuth.shared.isUserLoggedIn())
            
            SCAuth.shared.fetchAccessToken() { (accessToken, userID, error) in
                XCTAssertEqual(accessToken, "mocked_access_token")
                // then we logout
                SCAuth.shared.logout(logoutReason: .technicalReason, completion:{
                    XCTAssertNil(SCAuth.shared.getRefreshToken())
                    XCTAssertFalse(SCAuth.shared.isUserLoggedIn())
                    
                    logoutSuccessfulExpectation.fulfill()
                })
            }
        }
        
         wait(for: [logoutSuccessfulExpectation], timeout: 1)
    }
}

fileprivate class MockAuthRequest: SCRequestCreating, SCDataFetching {
    
    public let success: Bool
    
    private let loginJson = """
        {
        "status": "200 OK",
        "content": {
            "access_token": "mocked_access_token",
            "token_type": "bearer",
            "refresh_token": "mocked_refresh_token",
            "expires_in": 299,
            "scope": "email openid profile",
            "refresh_expires_in": 600
        },
        "message": "The access token Object"
        }
    """
    private let loginFailedJson = """
        {
            "error": {
                    "errorCode": "user.not.exist",
                    "userMsg": "User does not exists. Please register first to be able to use the application."
            },
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
        } else if url.absoluteString.contains("logout") {
            jsonString = logoutJson
        } else if url.absoluteString.contains("refreshedToken") {
            jsonString = refreshedJson
        } else {
            jsonString = "error"
        }
        
        let mockData = jsonString.data(using: .utf8)!
        
        self.success ? completion(.success(mockData)) : completion(.failure(SCRequestError.unauthorized(SCRequestErrorDetails.notAuthorized(clientTrace: ""))))
    }
    
    func uploadData(from url: URL, method: String, body: Data?, needsAuth: Bool, additionalHeaders: [String : String], completion: @escaping ((SCRequestResult) -> ())) {
        
    }
    
    func cancel(){
    }

}
