//
//  SCDefectReporterWorkerMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 25/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
@testable import OSCA

class SCDefectReporterWorkerMock: SCDefectReporterWorking {
    var defectCategory: [SCModelDefectCategory]?
    var error: SCWorkerError?
    var submitDefectStatus: String?
    var uploadDefectImageStatus: String?
    
    init(defectCategory: [SCModelDefectCategory]? = nil,
         error: SCWorkerError? = nil,
         submitDefectStatus: String? = nil,
         uploadDefectImageStatus: String? = nil) {
        self.defectCategory = defectCategory
        self.error = error
        self.submitDefectStatus = submitDefectStatus
        self.uploadDefectImageStatus = uploadDefectImageStatus
    }
    func getDefectCategories(cityId: String, completion: @escaping ([SCModelDefectCategory], SCWorkerError?) -> Void) {
        guard let defectCategory = defectCategory else {
            completion([], error)
            return
        }
        completion(defectCategory, nil)
    }
    
    func submitDefect(cityId: String, defectRequest: SCModelDefectRequest, completion: @escaping ((String?, SCWorkerError?) -> Void)) {
        guard let submitDefectStatus = submitDefectStatus else {
            completion(nil, error)
            return
        }
        completion(submitDefectStatus, nil)
    }
    
    func uploadDefectImage(cityId: String, imageData: Data, completion: @escaping ((String?, SCWorkerError?) -> Void)) {
        guard let uploadDefectImageStatus = uploadDefectImageStatus else {
            completion(nil, error)
            return
        }
        completion(uploadDefectImageStatus, nil)
    }
    
    
}

