//
//  SCCitizenSingleSurveyWorker.swift
//  OSCA
//
//  Created by Michael on 10.12.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCCitizenSingleSurveyWorking {
    func getSurvey(for surveyId: Int,
                   cityId: Int,
                   completion: @escaping ((SCModelCitizenSurvey? , SCWorkerError?) -> Void))
}

class SCCitizenSingleSurveyWorker: SCWorker {
    private let surveyApiPath = "/api/v2/smartcity/city/survey"
}

extension SCCitizenSingleSurveyWorker: SCCitizenSingleSurveyWorking {

    func getSurvey(for surveyId: Int,
                   cityId: Int,
                   completion: @escaping ((SCModelCitizenSurvey? , SCWorkerError?) -> Void)) {
        
        let queryDictionary = ["cityId": String(cityId),
                              "actionName": "GET_SurveyDetails",
                              "surveyId": String(surveyId)] as [String : String]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: self.surveyApiPath,
                                                       parameter: queryDictionary)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: true) { (result) in
            switch result {
            case .success(let fetchedData):
                do {
                    let surveyData = try JSONDecoder().decode(SCHttpModelResponse<SCModelCitizenSurvey>.self, from: fetchedData)
                    let survey = surveyData.content
                    completion(survey, nil)
               } catch {
                    completion(nil, SCWorkerError.technicalError)
                }

            case .failure(let error):
                debugPrint("SurveyWorker: requestFailed", error)
                completion(nil, self.mapRequestError(error))
            }
        }

    }
}
