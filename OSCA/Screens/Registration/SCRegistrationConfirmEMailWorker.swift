//
//  SCRegistrationConfirmEMailWorker.swift
//  OSCA
//
//  Created by Michael on 13.05.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCRegistrationConfirmEMailWorking  {
    func resendEmail(_ email: String, actionName: String, completion: @escaping ((_ successful: Bool, _ error: SCWorkerError?) -> Void))
    func validatePin(_ email: String, actionName: String, pin: String, completion: @escaping ((_ successful: Bool, _ error: SCWorkerError?) -> Void))
}


class SCRegistrationConfirmEMailWorker: SCWorker {
    let resendApiPath = "/api/v2/smartcity/userManagement"
    let validatePinApiPath = "/api/v2/smartcity/userManagement"
}

extension SCRegistrationConfirmEMailWorker: SCRegistrationConfirmEMailWorking {
    
    struct SCHttpResponseEMailConfirmation: Decodable {
        let isSuccessful: Bool
    }

    public func resendEmail(_ email: String, actionName: String, completion: @escaping ((_ successful: Bool, _ error: SCWorkerError?) -> Void)) {
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        
        let queryDictionary = ["cityId": cityID, "actionName": actionName] as [String : String] //TODO: what is up with those constantsi
        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.resendApiPath, parameter: queryDictionary )

        let bodyDict = ["email" : email.lowercased()] as [String : Any]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(false, SCWorkerError.technicalError)
            return
        }
        
        request.fetchData(from: url, method: "PUT", body: bodyData, needsAuth: false)
        { (result) in
            switch result {
                
            case .success(let fetchedData):
                 do {
                    let httpContent = try JSONDecoder().decode(SCHttpModelResponse<SCHttpResponseEMailConfirmation>.self, from: fetchedData)
                    
                    completion(httpContent.content.isSuccessful, nil)
                } catch {
                    completion(false, SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SCRegistrationConfirmEMailWorker: requestFailed", error)
                completion(false,self.mapRequestError(error))
            }
        }
    }

    public func validatePin(_ email: String, actionName: String, pin: String, completion: @escaping ((_ successful: Bool, _ error: SCWorkerError?) -> Void)) {
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif

        let queryDictionary = ["cityId": cityID, "actionName": actionName] as [String : String] //TODO: what is up with those constantsi
        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.validatePinApiPath, parameter: queryDictionary )

        let bodyDict = ["email" : email.lowercased(), "code" : pin] as [String : Any]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(false, SCWorkerError.technicalError)
            return
        }
        
        request.fetchData(from: url, method: "POST", body: bodyData, needsAuth: false)
        { (result) in
            switch result {
                
            case .success(let fetchedData):
                 do {
                    let httpContent = try JSONDecoder().decode(SCHttpModelResponse<SCHttpResponseEMailConfirmation>.self, from: fetchedData)
                    
                    completion(httpContent.content.isSuccessful, nil)
                } catch {
                    completion(false, SCWorkerError.technicalError)
                }

            case .failure(let error):
                completion(false,self.mapRequestError(error))
            }
        }
    }

}
