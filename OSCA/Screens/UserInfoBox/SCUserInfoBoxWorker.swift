//
//  SCUserInfoBoxWorker.swift
//  SmartCity
//
//  Created by Michael on 14.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

import Foundation

protocol SCUserInfoBoxWorking {
    func changeReadState(id : Int, newReadState : Bool, completion: @escaping ((_ error : SCWorkerError?) -> Void))
    func deleteMessage(id : Int, delete: Bool, completion: @escaping ((_ error : SCWorkerError?) -> Void))
}

protocol SCUserInfoBoxDetailWorking {
    func deleteMessage(id : Int, delete: Bool, completion: @escaping ((_ error : SCWorkerError?) -> Void))
}

class SCUserInfoBoxWorker: SCWorker {
    let apiPathReadState = "/api/v2/smartcity/infobox"
    let apiPathDelete = " /api/v2/smartcity/infobox"
}

extension SCUserInfoBoxWorker: SCUserInfoBoxWorking, SCUserInfoBoxDetailWorking {

    public func changeReadState(id : Int, newReadState : Bool, completion: @escaping ((_ error : SCWorkerError?) -> Void)) {

        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif

        let method = "PUT"
        let queries = ["msgId": String(id),
                       "markRead" : String(newReadState),
                       "cityId": cityID,
                       "actionName": "PUT_InfoBox"]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: apiPathReadState, parameter: queries)

        request.fetchData(from: url, method: method, body: nil, needsAuth: true) { (response) in
            switch response {
                
            case .success(let fetchedData):
                do {
                    _ = try JSONDecoder().decode(SCHttpModelBaseResponse.self, from: fetchedData)
                    completion(nil)
                } catch {
                    completion(SCWorkerError.technicalError)
                }

            case .failure(let error):
                completion(self.mapRequestError(error))
            }
        }
    }

    public func deleteMessage(id : Int, delete: Bool, completion: @escaping ((_ error : SCWorkerError?) -> Void)) {
        
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif

        let method = "DELETE"
        let queries = ["msgId": String(id),
                       "delete" : String(delete),
                       "cityId": cityID,
                       "actionName": "DELETE_InfoBox"]

        let url = GlobalConstants.appendURLPathToSOLUrl(path: apiPathReadState, parameter: queries)

        request.fetchData(from: url, method: method, body: nil, needsAuth: true) { (response) in
            switch response {
            case .success(let fetchedData):
                do {
                    _ = try JSONDecoder().decode(SCHttpModelBaseResponse.self, from: fetchedData)
                    completion(nil)
                } catch {
                    completion(SCWorkerError.technicalError)
                }

            case .failure(let error):
                completion(self.mapRequestError(error))
            }
        }
    }
}
