//
//  SCEditResidenceWorker.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 15/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

struct SCHttpResponseValidatePostcode: Decodable {
    let homeCityId: Int
    let cityName: String
    let postalCodeMessage: String
}

protocol SCEditResidenceWorking {
    func changeResidence(_ dob: String, postcode: String, completion: @escaping ((SCWorkerError?) -> ()))
    func validatePostalCode(_ postcode: String, completion: @escaping ((_ postalCodeInfo : SCHttpResponseValidatePostcode?, _ error: SCWorkerError?) -> Void))

}

class SCEditResidenceWorker: SCWorker {
    private let residenceChangeApiPath = "/api/v2/smartcity/userManagement"
    private let validatePostalCodeApiPath = "/api/v2/smartcity/userManagement"

}

extension SCEditResidenceWorker: SCEditResidenceWorking {
    
    
    public func changeResidence(_ dob: String, postcode: String, completion: @escaping ((SCWorkerError?) -> ())) {

        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        
        let queryDictionary = ["cityId": cityID,
                               "actionName": "PUT_ChangePersonalData",
                               "update" : "postalCode"] as [String : String]

        let bodyDict = ["dob" : dob,
                        "postalCode" : postcode] as [String : Any]
        
        let url = GlobalConstants.appendURLPathToSOLUrl(path: residenceChangeApiPath,
                                                        parameter: queryDictionary)

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
    
    public func validatePostalCode(_ postcode: String, completion: @escaping ((_ postalCodeInfo : SCHttpResponseValidatePostcode?, _ error: SCWorkerError?) -> Void)) {

        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        
        let bodyDict = ["cityId": cityID,
                               "actionName": "GET_PostalCodeValidation",
                               "postalCode" : postcode] as [String : String]


        let url = GlobalConstants.appendURLPathToSOLUrl(path: validatePostalCodeApiPath,
                                                        parameter: bodyDict)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in
            switch result {

            case .success(let fetchedData):
                do {
                    let httpContent = try JSONDecoder().decode(SCHttpModelResponse<SCHttpResponseValidatePostcode>.self, from: fetchedData)
                    
                    completion(httpContent.content, nil)
                } catch {
                    completion(nil, SCWorkerError.technicalError)
                }
            case .failure(let error):
                debugPrint("SCEditResidenceWorker: requestFailed", error)
                completion(nil, self.mapRequestError(error))
            }
        }
    }
}
