//
//  SCPWDRestoreUnlockWorker.swift
//  SmartCity
//
//  Created by Michael on 19.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCPWDRestoreUnlockWorking {
    func recoverPassword(_ email: String, pwd: String, completion: @escaping ((_ successful: Bool, _ error: SCWorkerError?) -> Void))
}

class SCPWDRestoreUnlockWorker: SCWorker {
    private let passwordRecoveryApiPath = "/api/v2/smartcity/userManagement"
}

extension SCPWDRestoreUnlockWorker: SCPWDRestoreUnlockWorking {
    
    struct SCHttpResponseRestoreConfirmation: Decodable {
        let isSuccessful: Bool
    }

    func recoverPassword(_ email: String, pwd: String, completion: @escaping ((_ successful: Bool, _ error: SCWorkerError?) -> Void)) {
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif

        let queryDictionary = ["cityId": cityID, "actionName": "POST_PasswordReset"] as [String : String] //TODO: what is up with those constantsi
        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.passwordRecoveryApiPath, parameter: queryDictionary )

        let bodyDict = ["newPassword" : pwd,
                        "email" : email.lowercased()] as [String : Any]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(false, SCWorkerError.technicalError)
            return
        }

        request.fetchData(from: url, method: "POST", body: bodyData, needsAuth: false)
            { (result) in
                switch result {
                    
                case .success(let fetchedData):
                     do {
                        let httpContent = try JSONDecoder().decode(SCHttpModelResponse<SCHttpResponseRestoreConfirmation>.self, from: fetchedData)
                        
                        completion(httpContent.content.isSuccessful, nil)
                    } catch {
                        completion(false, SCWorkerError.technicalError)
                    }

                case .failure(let error):
                    debugPrint("SCPWDRestoreUnlockWorker: requestFailed", error)
                    completion(false,self.mapRequestError(error))
                }
            }
        }
    }
