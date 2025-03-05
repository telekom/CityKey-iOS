/*
Created by Harshada Deshmukh on 15/02/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
