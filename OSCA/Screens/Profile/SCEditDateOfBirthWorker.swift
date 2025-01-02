//
//  SCEditDateOfBirthWorker.swift
//  OSCA
//
//  Created by Bharat Jagtap on 29/04/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCHttpResponseUpdateDateOfBirth: Decodable {
    
}

protocol SCEditDateOfBirthWorking {
    
    func updateDateOfBirth(_ dob: String, completion: @escaping ((SCWorkerError?) -> ()))
    func clearDateOfBirth( completion: @escaping ((SCWorkerError?) -> ()))
}

class SCEditDateOfBirthWorker: SCWorker {
    private let updateDateOfBirthAPIPath = "/api/v2/smartcity/userManagement"
}

extension SCEditDateOfBirthWorker: SCEditDateOfBirthWorking {
    
    
    func updateDateOfBirth(_ dob: String, completion: @escaping ((SCWorkerError?) -> ())) {
        
        
#if INT
        let cityID = "10"
#else
        let cityID = "8"
#endif
        
        let queryDictionary = [ "cityId": cityID,
                                "actionName": "PUT_ChangePersonalData",
                                "update" : "dob"] as [String : String]
        
        let bodyDict = ["dob" : dob, "postalCode" : ""] as [String : Any]
        
        let url = GlobalConstants.appendURLPathToSOLUrl(path: updateDateOfBirthAPIPath,
                                                        parameter: queryDictionary)
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(SCWorkerError.fetchFailed(SCWorkerErrorDetails(message: "error on encoding update DOB req body")))
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
    
    
    func clearDateOfBirth( completion: @escaping ((SCWorkerError?) -> ())) {
        
#if INT
        let cityID = "10"
#else
        let cityID = "8"
#endif
        
        let queryDictionary = [ "cityId": cityID,
                                "actionName": "PUT_ChangePersonalData",
                                "update" : "dob"] as [String : String]
        
        let bodyDict = ["dob" : NSNull(), "postalCode" : ""] as [String : Any]
        
        let url = GlobalConstants.appendURLPathToSOLUrl(path: updateDateOfBirthAPIPath,
                                                        parameter: queryDictionary)
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(SCWorkerError.fetchFailed(SCWorkerErrorDetails(message: "error on encoding update DOB req body")))
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
