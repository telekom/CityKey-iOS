//
//  SCFeedbackWorker.swift
//  OSCA
//
//  Created by Ayush on 10/09/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

struct FeedbackRequestModel {
    let cityID: String
    let currentCityName: String
    let aboutApp: String?
    let improvementOnApp: String?
    let email: String?
}

protocol SCFeedbackWorking {
    func sendfeedback(feedback: FeedbackRequestModel, completion: @escaping ((SCWorkerError?) -> ()))
}

class SCFeedbackWorker: SCWorker {
    private let sendFeedbackApiPath = "/api/v2/smartcity/city/cityService"
}

extension SCFeedbackWorker: SCFeedbackWorking {
    func sendfeedback(feedback: FeedbackRequestModel, completion: @escaping ((SCWorkerError?) -> ())) {
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        let queryParameter = ["cityId": cityID,"currentCityName": feedback.currentCityName, "actionName": "POST_SubmitFeedback"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: sendFeedbackApiPath, parameter: queryParameter)
        
        var body : Data? = nil
        let bodyDict = ["aboutApp" : feedback.aboutApp ?? "",
                        "improvementOnApp" : feedback.improvementOnApp ?? "",
                        "currentCityName": feedback.currentCityName,
                        "osInfo": "iOS:\(UIDevice.current.systemVersion)- \(SCUtilities.currentVersionAndEnv())",
                        "email": feedback.email ?? ""] as [String : Any]
        
        guard let bodyData = try? JSONSerialization.data(withJSONObject: bodyDict, options: []) else {
            completion(SCWorkerError.technicalError)
            return
        }
        body = bodyData
        
        request.fetchData(from: url, method: "POST", body: body, needsAuth: false) { (result) in
            switch result {
            case .success(_ ):
                completion(nil)
            case .failure(let error):
                completion(self.mapRequestError(error))
                
            }
        }
    }
}

