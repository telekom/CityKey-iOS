//
//  SCLoginWorker.swift
//  SmartCity
//
//  Created by Michael on 29.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCLoginWorking {
   func login(email: String, password: String, remember: Bool,
                    completion: @escaping (SCWorkerError?) -> ())
    
    func logout(completion: @escaping ()->())
    
    func lastLogoutResason() -> SCLogoutReason?
    
    func clearLogoutResason()
}

class SCLoginWorker: SCWorker {
    private let authProvider: SCLoginAuthProviding & SCLogoutAuthProviding
    
    init(requestFactory: SCRequestCreating, authProvider: SCLoginAuthProviding & SCLogoutAuthProviding) {
        self.authProvider = authProvider
        super.init(requestFactory: requestFactory)
    }
}

extension SCLoginWorker: SCLoginWorking {
    
    
    func login(email: String, password: String, remember: Bool,
                       completion: @escaping (SCWorkerError?) -> ()) {
        
        self.authProvider.login(name: email, password: password, remember: remember) { (error) in
             completion(error)
         }
    }

    func logout(completion: @escaping ()->()) {
        self.authProvider.logout(logoutReason: .technicalReason, completion:  completion)
        self.authProvider.clearLogoutReason()
    }

    func lastLogoutResason() -> SCLogoutReason?{
        return self.authProvider.logoutReason()
    }

    func clearLogoutResason(){
        self.authProvider.clearLogoutReason()
    }

}
