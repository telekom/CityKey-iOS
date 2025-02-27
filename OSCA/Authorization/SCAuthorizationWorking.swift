/*
Created by Robert Swoboda - Telekom on 11.04.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Robert Swoboda
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation

protocol SCAuthorizationWorking {
    func login(name: String, password: String,
               completion: @escaping ((SCWorkerError?, SCModelAuthorization?) -> ()))
    func logout(refreshToken: String,
                completion: @escaping ((SCWorkerError?, _ success: Bool) -> ()))

    func requestNewAccessToken(with refreshToken: String,
                               completion: @escaping (SCWorkerError?, _ authorization: SCModelAuthorization?) -> ())
}

class SCAuthorizationWorker: SCWorker, SCAuthorizationWorking {

    private let loginPath = "/api/v2/smartcity/userManagement"
    private let logoutApiPath = "/api/v2/smartcity/userManagement"
    private let refreshPath = "/api/v2/smartcity/userManagement"

    private let refreshTokenParameterName = "refreshToken"


    public func login(name: String, password: String,
                      completion: @escaping (SCWorkerError?, SCModelAuthorization?) -> ())
    {
        // SMARTC-16772 iOS: Implement Dialog when user Unexpectedly logouts
        SCUserDefaultsHelper.setLogOutEvent(true)

        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        let queryDictionary = ["cityId": cityID, "actionName": "POST_Login"] as [String : String]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: loginPath, parameter: queryDictionary)

        let bodyDict = ["email": name.lowercased(),
                        "password": password]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(SCWorkerError.fetchFailed(SCWorkerErrorDetails(message: "error on encoding")), nil)
            return
        }
        
        SCFileLogger.shared.write("Login Call | Path :\(url.absoluteString) | Query String : \(queryDictionary) | Body : \(bodyDict)" , withTag: .logout)
        
        request.fetchData(from: url, method: "POST", body: bodyData, needsAuth: false)
        { (response) in
            switch response {

            case .success(let fetchedData):
                do {
                    let httpModel = try JSONDecoder().decode(SCHttpModelResponse<SCHttpModelAuthorization>.self, from: fetchedData)
                    completion(nil, httpModel.content.toModel())
                } catch {
                    debugPrint("SCAuthorizationWorker: parsing failed", error)
                    completion(SCWorkerError.technicalError, nil)
                }
            case .failure(let error):
                switch error {
                case .unauthorized(let errorDetails):
                    // WORKAROUND: map unauthorize errors to a fetchfailed, because the middleware send us error response with http status 401
                    completion( SCWorkerError.fetchFailed(SCWorkerErrorDetails.init(message:errorDetails.userMsg, errorCode: errorDetails.errorCode)), nil)
                default:
                    debugPrint("SCAuthorizationWorker: requestFailed", error)
                    completion(self.mapRequestError(error), nil)
                }
            }
        }
    }

    func logout(refreshToken: String, completion: @escaping ((SCWorkerError?, _ success: Bool) -> ())) {
        
        // SMARTC-16772 iOS: Implement Dialog when user Unexpectedly logouts
        SCUserDefaultsHelper.setLogOutEvent(true)

        struct SCHttpLogout: Decodable {
            let isSuccessful: Bool
        }

        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        let queryDictionary = ["cityId": cityID, "actionName": "DELETE_Logout"] as [String : String]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: logoutApiPath, parameter: queryDictionary)

        let bodyDict = ["refreshToken": refreshToken]
        SCFileLogger.shared.write("Logout Call | Path :\(url.absoluteString) | Query String : \(queryDictionary) | Body : \(bodyDict)", withTag: .logout)
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(SCWorkerError.fetchFailed(SCWorkerErrorDetails(message: "error on encoding")), false)
            return
        }

        request.fetchData(from: url, method: "DELETE", body: bodyData, needsAuth: false)
        { (response) in
            switch response {
            case .success(let fetchedData):
                do {
                    let httpContent = try JSONDecoder().decode(SCHttpModelResponse<SCHttpLogout>.self, from: fetchedData  )
                    SCFileLogger.shared.write("Logout Success | \(httpContent.content.isSuccessful)", withTag: .logout)
                    completion(nil, httpContent.content.isSuccessful)
                } catch {
                    SCFileLogger.shared.write("Logout Failure | Exception parsing JSON response", withTag: .logout)
                    completion(SCWorkerError.technicalError, false)
                }
            case .failure(let error):
                SCFileLogger.shared.write("Logout Failure | SCAuthorizationWorker: requestFailed", withTag: .logout)
                debugPrint("SCAuthorizationWorker: requestFailed", error)
                completion(self.mapRequestError(error), false)
            }
        }
    }

    public func requestNewAccessToken(with refreshToken: String,
                                      completion: @escaping (SCWorkerError?, _ authorization: SCModelAuthorization?) -> ()) {
        
        // SMARTC-16772 iOS: Implement Dialog when user Unexpectedly logouts
        SCUserDefaultsHelper.setLogOutEvent(true)
        
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        
        let queryDictionary = ["cityId": cityID, "actionName": "POST_RefreshToken"] as [String : String]
        let requestBody = try! JSONEncoder().encode(["refreshToken" : refreshToken])
        let url = GlobalConstants.appendURLPathToSOLUrl(path: refreshPath, parameter: queryDictionary)
        
        SCFileLogger.shared.write("Request New Access Token Call | Path :\(url.absoluteString) | Query String : \(queryDictionary) | Body : \(["refreshToken" : refreshToken])", withTag: .logout)
        
        request.fetchData(from: url, method: "POST", body: requestBody, needsAuth: false) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let httpModel = try JSONDecoder().decode(SCHttpModelResponse<SCHttpModelAuthorization>.self, from: fetchedData)
                    
                    SCFileLogger.shared.write("Request New Access Token Call - Success | model : \(httpModel.content.toModel().description())", withTag: .logout)

                    completion(nil, httpModel.content.toModel())
                } catch {
                    
                    SCFileLogger.shared.write("Request New Access Token Call - Failure | Exception parsing JSON response ", withTag: .logout)
                    
                    completion(SCWorkerError.technicalError, nil)
                }
            case .failure(let error):
                SCFileLogger.shared.write("Request New Access Token Call - Failure | \(error) ", withTag: .logout)
                completion(self.mapRequestError(error), nil)
            }
        }
    }
}
