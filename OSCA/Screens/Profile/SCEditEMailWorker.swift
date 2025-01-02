//
//  SCEditEMailWorker.swift
//  SmartCity
//
//  Created by Michael on 21.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCEditEMailWorking {
    func changeEMail(_ email: String, completion: @escaping ((SCWorkerError?) -> ()))
}

class SCEditEMailWorker: SCWorker {
    private let eMailChangeApiPath = "/api/v2/smartcity/userManagement"
}

extension SCEditEMailWorker: SCEditEMailWorking {
    
    
    public func changeEMail(_ email: String, completion: @escaping ((SCWorkerError?) -> ())) {

        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        
        let bodyDict = ["cityId": cityID,
                               "actionName": "PUT_ChangeEmail",
                               "newEmail" : email.lowercased()] as [String : String]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: eMailChangeApiPath,
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
