//
//  SCLoginWorkerMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 28/06/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
@testable import OSCA

final class SCLoginWorkerMock: SCLoginWorking {
    let logoutReason: SCLogoutReason?
    private(set) var isClearLogoutReasonCalled: Bool = false
    
    init(logoutReason: SCLogoutReason? = nil) {
        self.logoutReason = logoutReason
    }
    
    func lastLogoutResason() -> SCLogoutReason? {
        return logoutReason
    }
    
    func clearLogoutResason() {
        isClearLogoutReasonCalled = true
    }
    
    func login(email: String, password: String, remember: Bool, completion: @escaping (SCWorkerError?) -> ()) {
        
        if email == "correct@email.com" {
            completion(nil)
        } else { completion(SCWorkerError.fetchFailed(SCWorkerErrorDetails.init(message: "Invalid user credentials. Please try again.", errorCode: "user.active")))
        }
    }
    
    func logout(completion: @escaping () -> ()) {
        completion()
    }
}


