//
//  SCDeleteAccountConfirmationWorker.swift
//  SmartCity
//
//  Created by Alexander Lichius on 09.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

private let loginPath = "/api/auth/login"
private let deletionPath = "/api/v2/smartcity/userManagement"

class SCDeleteAccountConfirmationWorker: SCWorker, SCDeleteAccountConfirmationWorking {
      
    func deleteAccount(_with password: String, completion: @escaping (SCWorkerError?) -> ()) {
        
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        
        let queryDictionary = ["cityId": cityID,
                               "actionName": "DELETE_UserAccount",
                               "password" : password] as [String : String]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: deletionPath,
                                                        parameter: queryDictionary)

        guard let bodyData = try? JSONSerialization.data(withJSONObject: queryDictionary, options: []) else {
            completion(SCWorkerError.fetchFailed(SCWorkerErrorDetails(message: "error on encoding password")))
            return
        }
        request.fetchData(from: url, method: "DELETE", body: bodyData, needsAuth: true) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    _ = try JSONDecoder().decode(SCHttpModelBaseResponse.self, from: fetchedData)
                    completion(nil)
                } catch {
                    completion(SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCDeleteAccountConfirmationWorker: requestFailed", error)
                completion(self.mapRequestError(error))
            }
        }
    }
}
