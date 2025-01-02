//
//  SCCitizenSurveyWorker.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 09/12/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
