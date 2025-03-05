/*
Created by Rutvik Kanbargi on 09/12/20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation

protocol SCCitizenSurveyWorking {
    var surveyDataState: SCWorkerDataState { get }

    func getSurveyOverview(ciyId: String,
                           completion: @escaping (([SCModelCitizenSurveyOverview], SCWorkerError?) -> Void))
    func submitSurvey(ciyId: String, surveyId: String, surveyResult: SCModelSurveyResult, completion: @escaping (Bool, SCWorkerError?) -> Void)
    func fetchDataPrivacyNoticeForPolls(ciyId: String, completionHandler: @escaping (DataPrivacyNotice?, SCWorkerError?) -> Void)
}

class SCCitizenSurveyWorker: SCWorker {
    private let surveyPath = "/api/v2/smartcity/city/survey"
    var surveyDataState = SCWorkerDataState()
}

extension SCCitizenSurveyWorker: SCCitizenSurveyWorking {

    func getSurveyOverview(ciyId: String, completion: @escaping (([SCModelCitizenSurveyOverview], SCWorkerError?) -> Void)) {

        let queryParameter = ["cityId": ciyId, "actionName": "GET_CitySurvey"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: surveyPath, parameter: queryParameter)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: true) { (result) in
            switch result {
            case .success(let response):
                do {
                    let survey = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpModelCitizenSurveyOverview]>.self, from: response)
                    completion(survey.content.map {$0.toModel()}, nil)
                } catch let error {
                    debugPrint("SCCitizenSurveyWorker: \(error)")
                    completion([], .technicalError)
                }

            case .failure(let error):
                debugPrint("SCCitizenSurveyWorker: \(error)")
                completion([], self.mapRequestError(error))
            }
        }
    }

    func submitSurvey(ciyId: String, surveyId: String, surveyResult: SCModelSurveyResult, completion: @escaping (Bool, SCWorkerError?) -> Void) {
        let queryParameter = ["cityId": ciyId, "actionName": "POST_UserSurvey", "surveyId": surveyId]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: surveyPath, parameter: queryParameter)

        let body = try? JSONEncoder().encode(surveyResult.self)

        request.fetchData(from: url, method: "POST", body: body, needsAuth: true) { (result) in
            switch result {
            case .success( _):
                completion(true, nil)
            case .failure(let error):
                debugPrint("SCCitizenSurveyWorker Submit survey: \(error)")
                completion(false, self.mapRequestError(error))
            }
        }
    }

    func fetchDataPrivacyNoticeForPolls(ciyId: String, completionHandler: @escaping (DataPrivacyNotice?, SCWorkerError?) -> Void) {
        let queryParameter = [SCServiceRequest.Key.cityId: ciyId,
                              SCServiceRequest.Key.actionName: SCServiceRequest.Value.ActionName.GetDpnText]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: surveyPath, parameter: queryParameter)
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: true) { (result) in
            switch result {
            case .success(let response):
                do {
                    let dpn = try JSONDecoder().decode(DataPrivacyNotice.self, from: response)
                    completionHandler(dpn, nil)
                } catch {
                    completionHandler(nil, .technicalError)
                }
            case .failure(let error):
                completionHandler(nil, self.mapRequestError(error))
            }
        }
        
    }
}
