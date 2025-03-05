/*
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/
//
//  SCVersionCheckWorker
//  SmartCity
//
//  Created by Michael on 23.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//
import Foundation

protocol SCVersionCheckWorking {
    func checkVersionInfo(completion: @escaping ((_ error : SCWorkerError?, _ versionSupported: Bool, _ unspportedVersionMessage: String?) -> Void))
}

class SCVersionCheckWorker: SCWorker, SCVersionCheckWorking {
    
    let versionApiPath = "/api/v2/smartcity/city/appVersion"
    
    public func checkVersionInfo(completion: @escaping ((_ error : SCWorkerError?, _ versionSupported: Bool, _ unspportedVersionMessage: String?) -> Void)) {
#if INT
        let cityID = "10"
#else
        let cityID = "8"
#endif
        let queryParameter = ["cityId": cityID,
                              "actionName": "GET_AppVersion",
                              "appVersion": "\(SCVersionHelper.appVersion())",
                              "osName": "iOS"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: versionApiPath, parameter: queryParameter)
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (response) in
            switch response {
                
            case .success(let fetchedData):
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: fetchedData, options:[]) as? Dictionary<String,AnyObject>
                    print("Json: \(String(describing: jsonData))")
                    if let contentArray = jsonData?["content"] as? NSArray {
                        if let dict = contentArray[0] as? Dictionary<String,AnyObject> {
                            if dict["result"] as! String == "SUCCESS" {
                                completion(nil, true, nil)
                            } else {
                                completion(nil, false, nil)
                            }
                        }
                    }
                }
                catch {
                    print("Not Serialized")
                }
            case .failure(let error):
                switch error {
                case .requestFailed(_ , _):
                    // We are not handling error for GET_AppVersion API, so that user will not be blocked from using the application
                    completion(nil, true, nil)
                default:
                    completion(nil, true, nil)
                }
            }
        }
    }
}

