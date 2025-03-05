/*
Created by Robert Swoboda - Telekom on 19.06.19.
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

protocol SCLocationWorking {
    func fetchCityId(for latitude: Double, longitude: Double, completion: @escaping (_ error: SCWorkerError?, _ cityId: Int?, _ distance : Double?) -> Void)
}

class SCLocationWorker: SCWorker {
    private let apiPath = "/api/postalCode/cityContent"
    private let cityLocationApiPath = "/api/v2/smartcity/city/cityService"
}


extension SCLocationWorker: SCLocationWorking {
    func fetchCityId(for latitude: Double, longitude: Double, completion: @escaping (SCWorkerError?, Int?, Double?) -> Void) {
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        let queryDictionary = ["LAT": String(latitude), "LNG": String(longitude), "cityId": cityID, "actionName": "GET_NearestCityId"] as [String : String]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: cityLocationApiPath, parameter: queryDictionary)
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (response) in
            switch response {
            case .success(let fetchedData):
                do {
                    let httpmodel = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpModelCityId]>.self, from: fetchedData)
                    completion(nil, httpmodel.content.first?.cityId, httpmodel.content.first?.distance)
                } catch {
                    completion(SCWorkerError.technicalError,nil, nil)
                }
            case .failure(let error):
                debugPrint("SCLocationWorker: requestFailed failed", error)
                completion(self.mapRequestError(error), nil, nil)
            }
        }
    }
    
}
