/*
Created by Michael on 19.06.19.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
