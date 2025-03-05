/*
Created by Bharat Jagtap on 21/04/21.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation

protocol SCEgovServiceWorking {

    var egovDataState: SCWorkerDataState { get }
    var groups : [SCModelEgovGroup]? { get }
    func getEgovGroups(cityId: String,
                           completion: @escaping (([SCModelEgovGroup], SCWorkerError?) -> Void))
    func getEgovHelpHTMLText(cityId: String,
                           completion: @escaping ( String , SCWorkerError?) -> Void)
}

class SCEgovServiceWorker : SCWorker {
    
    var groups : [SCModelEgovGroup]?
    private let egovAPIPath = "/api/v2/smartcity/egov"
    var egovDataState = SCWorkerDataState(dataInitialized: false, dataLoadingState: .needsToBefetched)
    
}

extension SCEgovServiceWorker: SCEgovServiceWorking {

    func getEgovGroups(cityId: String, completion: @escaping (([SCModelEgovGroup], SCWorkerError?) -> Void)) {

        if egovDataState.dataLoadingState == .fetchedWithSuccess {
            completion(self.groups ?? [] , nil);
        } else {
            fetchEgovGroups(cityId: cityId, completion: completion)
        }
    }
    
    func getEgovHelpHTMLText(cityId: String,
                             completion: @escaping ( String , SCWorkerError?) -> Void) {
        
        let queryParameter = ["cityId": cityId, "actionName": "GET_HelpContent"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: egovAPIPath, parameter: queryParameter)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in
            
            print("result", result)

            switch result {
            case .success(let response):
                do {
                    struct EgovHelpContent : Codable {
                        let textId : Int
                        let helpText : String
                    }

                    let httpResponseModel = try JSONDecoder().decode(SCHttpModelResponse<[EgovHelpContent]>.self, from: response)
                    completion( httpResponseModel.content.first?.helpText ?? "" , nil)
                    
                } catch (let error) {
                    debugPrint("Error passing egov groups response : \(error)")
                    self.egovDataState.dataLoadingState = .fetchFailed
                    completion("", .technicalError)
                }

            case .failure(let error):
                self.egovDataState.dataLoadingState = .fetchFailed
                debugPrint("SCEgovServiceWorker -> fetchEgovGroups() -> Error : \(error)")
                completion("", self.mapRequestError(error))
            }
        }
    }
    
    private func fetchEgovGroups(cityId: String, completion: @escaping (([SCModelEgovGroup], SCWorkerError?) -> Void)) {

        self.egovDataState.dataLoadingState = .fetchingInProgress

        let queryParameter = ["cityId": cityId, "actionName": "GET_CityServices"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: egovAPIPath, parameter: queryParameter)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in
            
            print("result", result)

            switch result {
            case .success(let response):
                do {
                    
                    let groupsHTTPModels = try JSONDecoder().decode(SCHttpModelResponse<[SCHTTPModelEgovGroup]>.self, from: response)
                    let groupsModel = groupsHTTPModels.content.map { $0.toModel() }
                    self.groups = groupsModel
                    self.egovDataState.dataInitialized = true
                    self.egovDataState.dataLoadingState = .fetchedWithSuccess
                    completion(self.groups ?? [] , nil)
                } catch (let error) {
                    debugPrint("Error passing egov groups response : \(error)")
                    self.egovDataState.dataLoadingState = .fetchFailed
                    completion([], .technicalError)
                }

            case .failure(let error):
                self.egovDataState.dataLoadingState = .fetchFailed
                debugPrint("SCEgovServiceWorker -> fetchEgovGroups() -> Error : \(error)")
                completion([], self.mapRequestError(error))
            }
        }
    }
}



