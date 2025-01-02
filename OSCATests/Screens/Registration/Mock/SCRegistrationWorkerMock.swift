//
//  SCRegistrationWorkerMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 02/07/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
@testable import OSCA

class SCRegistrationWorkerMock: SCRegistrationWorking {
    var isRegistrationSuccess: Bool
    var error: SCWorkerError?
    init(isRegistrationSuccess: Bool = false, error: SCWorkerError? = nil) {
        self.isRegistrationSuccess = isRegistrationSuccess
        self.error = error
    }
    
    func register(registration: OSCA.SCModelRegistration, completion: @escaping ((Bool, String?, OSCA.SCWorkerError?) -> Void)) {
        if isRegistrationSuccess {
            completion(true, "Musterstadt,Model State is supported!", nil)
        } else {
            completion(false, nil, error)
        }
    }
}
