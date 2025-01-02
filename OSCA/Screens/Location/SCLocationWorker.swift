//
//  SCLocationWorker.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 19.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
