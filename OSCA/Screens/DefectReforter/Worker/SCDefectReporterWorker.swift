/*
Created by Harshada Deshmukh on 04/05/21.
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

import Foundation
import UIKit

protocol SCDefectReporterWorking {
    
    func getDefectCategories(cityId: String, completion: @escaping ([SCModelDefectCategory], SCWorkerError?) -> Void)
    func submitDefect(cityId: String, defectRequest: SCModelDefectRequest, completion: @escaping ((_ uniqueId : String?, _ error: SCWorkerError?) -> Void))
    func uploadDefectImage(cityId: String, imageData: Data, completion: @escaping ((_ mediaURL : String?, _ error: SCWorkerError?) -> Void))

}

class SCDefectReporterWorker: SCWorker {
    private var defectCategories : [SCModelDefectCategory]?

    private let defectReporterPath = "/api/v2/smartcity/defectReporter"
    private let defectReporterImageUploadPath = "/api/v2/smartcity/otc/upload"

}

extension SCDefectReporterWorker: SCDefectReporterWorking {
    
    func getDefectCategories(cityId: String, completion: @escaping (([SCModelDefectCategory], SCWorkerError?) -> Void)) {
    
        let queryParameter = ["cityId": cityId, "actionName": "GET_CityDefectCategories"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: defectReporterPath, parameter: queryParameter)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in
            print("result", result)

            switch result {
            case .success(let response):
                do {
                    let defectCategory = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpModelDefectCategory]>.self, from: response)
                    let defectCategoryContent = defectCategory.content.map {$0.toModel()}
                    self.defectCategories = defectCategoryContent

                    completion(defectCategoryContent, nil)
                } catch {
                    completion([], .technicalError)
                }

            case .failure(let error):
                debugPrint("SCDefectReporterWorker: \(error)")
                completion([], self.mapRequestError(error))
            }
        }
    }

    struct SCHttpResponseDefectRequest: Decodable {
        let uniqueId: String
    }
    
    func submitDefect(cityId: String, defectRequest: SCModelDefectRequest, completion: @escaping ((_ uniqueId : String?, _ error: SCWorkerError?) -> Void)) {

        let queryDictionary = ["cityId": cityId, "actionName": "POST_CityDefect"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: defectReporterPath, parameter: queryDictionary )
        
        let bodyDict = defectRequest.toModel()
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(nil, SCWorkerError.technicalError)
            return
        }
        
        request.fetchData(from: url, method: "POST", body: bodyData, needsAuth: false)
        { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let httpContent = try JSONDecoder().decode(SCHttpModelResponse<SCHttpResponseDefectRequest>.self, from: fetchedData)
                    debugPrint("SCDefectReporterWorker: ", httpContent.content.uniqueId)

                    completion(httpContent.content.uniqueId, nil)
                } catch {
                    completion(nil, SCWorkerError.technicalError)
                }
            case .failure(let error):
                debugPrint("SCDefectReporterWorker: requestFailed", error)
                completion(nil, self.mapRequestError(error))
            }
        }
    }
    
    struct SCHttpResponseDefectImageRequest: Decodable {
        let mediaURL: String
    }
    
    // SMARTC-20455 : Defect reporter image is not compressing to 2MB , if the file size is greater than 5MB
    func uploadDefectImage(cityId: String, imageData: Data, completion: @escaping ((_ mediaURL : String?, _ error: SCWorkerError?) -> Void)) {

        let queryDictionary = ["cityId": cityId, "actionName": "POST_Image"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: defectReporterImageUploadPath, parameter: queryDictionary )
             
        let additionalHeaders = ["Content-Type": "image/jpeg",
                                 "Content-Length": "\(imageData.count)"]
        
        request.uploadData(from: url, method: "POST", body: imageData, needsAuth: false, additionalHeaders: additionalHeaders)
        { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let httpContent = try JSONDecoder().decode(SCHttpModelResponse<SCHttpResponseDefectImageRequest>.self, from: fetchedData)
                    debugPrint("SCDefectReporterWorker: ", httpContent.content.mediaURL)

                    completion(httpContent.content.mediaURL, nil)
                } catch {
                    completion(nil, SCWorkerError.technicalError)
                }
            case .failure(let error):
                debugPrint("SCDefectReporterWorker: requestFailed", error)
                completion(nil, self.mapRequestError(error))
            }
        }
    }
}
