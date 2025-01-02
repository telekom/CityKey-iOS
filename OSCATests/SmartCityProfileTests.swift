//
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
