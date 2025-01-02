//
//  SCEgovServiceWorker.swift
//  OSCA
//
//  Created by Bharat Jagtap on 21/04/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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



