//
//  SCRegistrationWorker.swift
//  SmartCity
//
//  Created by Michael on 04.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCRegistrationWorking {
    func register(registration: SCModelRegistration, completion: @escaping ((_ successful: Bool, _ postalCodeInfo : String?, _ error: SCWorkerError?) -> Void))
}


class SCRegistrationWorker: SCWorker {
    let registrationApiPath = "/api/v2/smartcity/userManagement"
}

extension SCRegistrationWorker: SCRegistrationWorking {

    struct SCHttpResponseRegistration: Decodable {
        let isSuccessful: Bool
        let postalCode: String
    }

    public func register(registration: SCModelRegistration, completion: @escaping ((_ successful: Bool, _ postalCodeInfo : String?, _ error: SCWorkerError?) -> Void))
    {
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif

        let queryDictionary = ["cityId": cityID, "actionName": "POST_RegisterNewUser"] as [String : String] //TODO: what is up with those constantsi
        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.registrationApiPath, parameter: queryDictionary )

        let bodyDict = ["dateOfBirth" : registration.birthdate ?? NSNull(),
                        "email" : registration.eMail.lowercased(),
                        "postalCode": registration.postalCode,
                        "password": registration.pwd] as [String : Any]
        
        debugPrint("SCRegistrationWorker: register with dict:", bodyDict)

        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(false, nil, SCWorkerError.technicalError)
            return
        }
        
        request.fetchData(from: url, method: "POST", body: bodyData, needsAuth: false)
        { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let httpContent = try JSONDecoder().decode(SCHttpModelResponse<SCHttpResponseRegistration>.self, from: fetchedData)
                    
                    completion(httpContent.content.isSuccessful , httpContent.content.postalCode, nil)
                } catch {
                    completion(false, nil, SCWorkerError.technicalError)
                }
            case .failure(let error):
                debugPrint("SCRegistrationWorker: requestFailed", error)
                completion(false, nil, self.mapRequestError(error))
            }
        }
    }
    
}
