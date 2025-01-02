//
//  SCPWDRestoreUnlockFinishedWorker.swift
//  SmartCity
//
//  Created by Michael on 19.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCPWDRestoreUnlockFinishedWorking {
    func recoverPassword(_ email: String, pwd: String, completion: @escaping ((SCWorkerError?) -> ()))
}


class SCPWDRestoreUnlockFinishedWorker: SCWorker {
    private let passwordRecoveryApiPath = "/api/user/password"
}

extension SCPWDRestoreUnlockFinishedWorker: SCPWDRestoreUnlockFinishedWorking {
    
    
    public func recoverPassword(_ email: String, pwd: String, completion: @escaping ((SCWorkerError?) -> ())) {
        
        /*
        let url = GlobalConstants.appendURLPathToMiddlewareUrl(path: passwordRecoveryApiPath, parameter: nil)
        
        request.fetchData(from: url, method: "POST", body: email.data(using: .utf8), needsAuth: false) { (result) in
            switch result {
            case .success(_ ):
                completion(nil)
            case .failure(let error):
                debugPrint("SCPWDRestoreUnlockWorker: requestFailed", error)
                completion(self.mapRequestError(error))
            }
        }*/
    }
    
}
