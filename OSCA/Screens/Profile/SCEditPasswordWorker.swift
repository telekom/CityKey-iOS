//
//  SCEditPasswordWorker.swift
//  SmartCity
//
//  Created by Michael on 21.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCEditPasswordWorking {
    func changePassword(currentPassword: String, newPassword: String, completion: @escaping ((SCWorkerError?) -> ()))
}

class SCEditPasswordWorker: SCWorker {
    private let passwordChangeApiPath = "/api/v2/smartcity/userManagement"
}

extension SCEditPasswordWorker: SCEditPasswordWorking {
    
    public func changePassword(currentPassword: String, newPassword: String, completion: @escaping ((SCWorkerError?) -> ())) {
        
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        
        let bodyDict = ["cityId": cityID,
                               "actionName": "PUT_ChangePassword",
                               "oldPwd" : currentPassword,
                               "newPwd" : newPassword] as [String : String]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: passwordChangeApiPath,
                                                        parameter: bodyDict)

        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(SCWorkerError.fetchFailed(SCWorkerErrorDetails(message: "error on encoding email")))
            return
        }
        
        request.fetchData(from: url, method: "PUT", body: bodyData, needsAuth: true) { (result) in
            switch result {
            case .success(_ ):
                completion(nil)
            case .failure(let error):
                completion(self.mapRequestError(error))
            }
        }
    }
}
