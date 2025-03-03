/*
Created by A118572539 on 03/01/22.
Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, A118572539
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

protocol TPNSNetworkClient: TPNSWorking {
    
}

import Foundation

/// Class responsible for creating request object for TPNS
class SCTPNSClient {
    
    private let registerDevicePath = "/api/device/register"
    let tpnsURL = ""
    
    // TPNS required parameters
    let appKey = "com.telekom.opensource.citykey"
    
    let applicationType = "IOS"
    let uniqueDeviceID = SCDeviceUniqueID.shared.getDeviceUniqueID()
    
    private let executor: SCNetworkCallsExecutor
    
    init(executor: SCNetworkCallsExecutor) {
        self.executor = executor
    }
    
    // MARK: Private Methods
    
    private func createURLForUnregisteringPushForUser() -> String {
        if let uniqueDeviceID = uniqueDeviceID {
            let url = "\(tpnsURL)/api/application/\(appKey)/device/\(uniqueDeviceID)/unregister"
            return url
        }
        
      return ""
    }
    
    private func createRequestForTPNS(with url: URL,
                                      method: String,
                                      body: Data?) -> URLRequest {
        var request = URLRequest(url: url)
        
        request.httpMethod = method
        request.httpBody = body
        
        // Header Configuration
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    private func sendRequest(with url: URL,
                             method: String,
                             body: Data?,
                             retryCountIfFailure: UInt? = 0,
                             completion: @escaping SCRequestCompletionBlock) {
        
        let request = createRequestForTPNS(with: url, method: method, body: body)
        
        executor.executeRequest(with: request,
                                maxAttempts: retryCountIfFailure) { data, response, error in
            guard error == nil else {
                completion(.failure(SCRequestError.unexpected(SCRequestErrorDetails.unexpectedError(clientTrace: "Internet Issue"))))
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                completion(.failure(SCRequestError.unexpected(SCRequestErrorDetails.invalidResponse(clientTrace: "SCRequest: unkown http code"))))
                return
            }
            
            switch httpStatusCode {
            case 200:
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        if let success = json["success"], success as! Bool {
                            print("Device Successfully registered")
                            completion(.success(data!))
                        }
                    }
                } catch _ {
                    _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                }
            case 422:
                completion(.failure(SCRequestError.unexpected(SCRequestErrorDetails.unexpectedError(clientTrace: "Application Key is Invalid"))))
            default:
                completion(.failure(SCRequestError.unexpected(SCRequestErrorDetails.invalidResponse(clientTrace: "SCRequest: unkown http code"))))
            }
        }
    }
}

extension SCTPNSClient: TPNSNetworkClient {
    func registerForPush(with additionalParameters: [String : String], registrationID: String, completion: @escaping ((Bool, SCWorkerError?) -> Void)) {
        var additionalParametersArray: [Dictionary<String, String>] = []
        
        for (key, value) in additionalParameters {
            additionalParametersArray.append(["key": key, "value": value] as Dictionary<String, String>)
        }
        
        let bodyDict = ["applicationType": applicationType,
                        "applicationKey": appKey ,
                        "deviceId": uniqueDeviceID ?? "",
                        "deviceRegistrationId": registrationID,
                        "additionalParameters": additionalParametersArray] as [String : Any]
        print(bodyDict)
        
        let url = GlobalConstants.appendURLPathToUrlString(tpnsURL,
                                                           path: registerDevicePath,
                                                           parameter: [:],
                                                           appendPathToURLStringpath: true)
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(false, SCWorkerError.technicalError)
            return
        }
        print(bodyData)
        
        self.sendRequest(with: url, method: "POST", body: bodyData, retryCountIfFailure: 3) { result in
            // result for register API
        }
    }
    
    func unRegisterForPush(completion: @escaping ((Bool, SCWorkerError?) -> Void)) {
        let url = URL(string: createURLForUnregisteringPushForUser())
        if let url = url {
            sendRequest(with: url, method: "PUT", body: nil) { result in
                // result for unRegistered API
            }
        }
    }
}
