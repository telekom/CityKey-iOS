//
//  SCDefectReporterWorker.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 04/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
