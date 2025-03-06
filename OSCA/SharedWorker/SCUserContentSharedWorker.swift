/*
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/
//
//  SCUserContentSharedWorker
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 04.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCUserContentUserIdentifing {
    func getUserID() -> String?
    func observeUserID(completion: @escaping (String?) -> Void)
    func getCityID() -> String?
    func observeCityID(completion: @escaping (String?) -> Void)
}

protocol SCUserContentDeleting {
    func clearData()
}

protocol SCUserContentSharedWorking : (SCUserContentUserIdentifing & SCUserContentDeleting) {
    
    var userDataState: SCWorkerDataState { get }
    var infoBoxDataState: SCWorkerDataState { get }

    func isUserDataAvailable() -> Bool
    func isUserDataLoading() -> Bool
    func isUserDataLoadingFailed() -> Bool
    func getUserData() -> SCModelUserData?
    func triggerUserDataUpdate(errorBlock: @escaping (SCWorkerError?)->())
    
    func isInfoBoxDataAvailable() -> Bool
    func isInfoBoxDataLoading() -> Bool
    func isInfoBoxDataLoadingFailed() -> Bool
    func getInfoBoxData() -> [SCModelInfoBoxItem]?
    func triggerInfoBoxDataUpdate(errorBlock: @escaping (SCWorkerError?)->())

    func markInfoBoxItem(id : Int, read : Bool)
    func removeInfoBoxItem(id : Int)

    func clearData()
}

class SCUserContentSharedWorker: SCWorker {

    private var userData: SCModelUserData? {
        didSet {
            if userData?.userID != oldValue?.userID {
                // after change of userod call the registered completion handler
                for completion in self.userIDObserver {
                    SCUserDefaultsHelper.setUserID(userData?.userID ?? "-1")
                    completion(userData?.userID)
                }
            }
            
            if userData?.cityID != oldValue?.cityID {
                // after change of cityid call the registered completion handler
                for completion in self.cityIDObserver {
                    completion(userData?.cityID)
                }
            }
        }
    }
    
    internal var userDataState = SCWorkerDataState()
    internal var infoBoxDataState = SCWorkerDataState()

    private var infoBoxData: [SCModelInfoBoxItem]?
    private var isInfoBoxDataFetching: Bool = false
    private var infoBoxDataLoadingFailed: Bool = false
    
    private var userIDObserver: [(String?) -> Void] = []
    private var cityIDObserver: [(String?) -> Void] = []

}

extension SCUserContentSharedWorker: SCUserContentSharedWorking, SCUserContentUserIdentifing {
    
    func observeUserID(completion: @escaping (String?) -> Void) {
        self.userIDObserver.append(completion)
    }
    
    func observeCityID(completion: @escaping (String?) -> Void) {
        self.cityIDObserver.append(completion)
    }

    func getUserID() -> String?{
        return self.userData?.userID
    }
    
    func getCityID() -> String?{
        return self.userData?.cityID
    }
    
    func isUserDataAvailable() -> Bool {
        return self.userDataState.dataInitialized
    }
    
    func isInfoBoxDataAvailable() -> Bool {
        return self.infoBoxDataState.dataInitialized
    }

    func isUserDataLoading() -> Bool {
        return self.userDataState.dataLoadingState == .fetchingInProgress
    }

    func isInfoBoxDataLoading() -> Bool {
        return self.infoBoxDataState.dataLoadingState == .fetchingInProgress
    }

    func isUserDataLoadingFailed() -> Bool {
        return self.userDataState.dataLoadingState == .fetchFailed
    }

    func isInfoBoxDataLoadingFailed() -> Bool {
        return self.infoBoxDataState.dataLoadingState == .fetchFailed
    }

    func getUserData() -> SCModelUserData? {
        return self.userData
    }

    func getInfoBoxData() -> [SCModelInfoBoxItem]? {
        return self.infoBoxData
    }

    func markInfoBoxItem(id : Int, read : Bool) {
        guard self.infoBoxData != nil, self.infoBoxData!.count > 0 else { return }
        for i in self.infoBoxData!.indices {
            if self.infoBoxData![i].userInfoId == id {
                self.infoBoxData![i].isRead = read
            }
        }
    }

    func removeInfoBoxItem(id : Int) {
        guard self.infoBoxData != nil, self.infoBoxData!.count > 0 else { return }
        self.infoBoxData?.removeAll(where: { (infoBoxItem) -> Bool in
            infoBoxItem.userInfoId == id
        })
    }

    func clearData(){
        self.userData = nil
        self.infoBoxData = nil
        self.userDataState = SCWorkerDataState()
        self.infoBoxDataState = SCWorkerDataState()
    }

    func triggerUserDataUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        guard self.userDataState.dataLoadingState != .fetchingInProgress else {
            SCUtilities.delay(withTime: 0.0, callback: {errorBlock(nil)})
            
            return
        }
        
        self.userDataState.dataLoadingState = .fetchingInProgress
        SCDataUIEvents.postNotification(for: .didChangeUserDataState)

        self.fetchUserData { (error, userData) in
            guard error == nil else {
                self.userDataState.dataLoadingState = .fetchFailed
                SCDataUIEvents.postNotification(for: .didChangeUserDataState)
                errorBlock(error)
                return
            }
            debugPrint("SCUserContentSharedWorker->fetchUserData userData =", userData as Any)
            self.userData = userData
            
            self.userDataState.dataInitialized = true
            self.userDataState.dataLoadingState = .fetchedWithSuccess

            debugPrint("SCUserContentSharedWorker->postNotification didReceiveUserData")

            errorBlock(nil)
            
            SCUtilities.delay(withTime: 0.0, callback: {
                SCDataUIEvents.postNotification(for: .didChangeUserDataState)
            })

        }
    }

    func triggerInfoBoxDataUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        guard self.infoBoxDataState.dataLoadingState != .fetchingInProgress else {
            SCUtilities.delay(withTime: 0.0, callback: {errorBlock(nil)})
            
            return
        }
        
        self.infoBoxDataState.dataLoadingState = .fetchingInProgress
        self.infoBoxDataState.dataInitialized = false
        self.fetchInfoBoxData { (error, infoBoxData) in
            guard error == nil else {
                self.infoBoxDataState.dataLoadingState = .fetchFailed
                errorBlock(error)
                return
            }
            self.infoBoxData = infoBoxData
            
            self.infoBoxDataState.dataInitialized = true
            self.infoBoxDataState.dataLoadingState = .fetchedWithSuccess
            errorBlock(nil)

            SCUtilities.delay(withTime: 0.0, callback: {
                SCDataUIEvents.postNotification(for: .didReceiveInfoBoxData)
            })
        }
    }
 
}


// the actual fetching, POSTing and DELETEing
extension SCUserContentSharedWorker {
    
    private func fetchUserData(completion:@escaping ((SCWorkerError?, SCModelUserData?) -> Void)) {

        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif

        let queryDictionary = ["cityId": cityID, "actionName": "GET_UserProfile"] as [String : String] //TODO: what is up with
        
        let userProfileApiPath = "/api/v2/smartcity/userManagement"
        let url = GlobalConstants.appendURLPathToSOLUrl(path: userProfileApiPath, parameter: queryDictionary)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: true) { (response) in
            switch response {
                
            case .success(let fetchedData):
                do {
                    let httpModel = try JSONDecoder().decode(SCHttpModelResponse<SCHttpModelUserData>.self, from: fetchedData)
                    let profile = httpModel.content.toModel()
                    completion(nil, profile)
                } catch {
                    debugPrint("SCUserContentSharedWorker->fetchUserData: parsing failed with \(error) for endpoint \(url)")
                    SCFileLogger.shared.write("Harshada -> fetchUserData | SCUserContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)

                    completion(SCWorkerError.technicalError, nil)
                    SCDataUIEvents.postNotification(for: .userDataLoadingFailed)
                }
                
            case .failure(let error):
                debugPrint("SCUserContentSharedWorker->fetchUserData: request failed failed with \(error) for endpoint \(url)")
                SCFileLogger.shared.write("Harshada -> fetchUserData | SCUserContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)

                let workerError = self.mapRequestError(error)
                
                completion(self.mapRequestError(error), nil)
                SCDataUIEvents.postNotification(for: .userDataLoadingFailed, info: workerError)

            }
        }
    }

    private func fetchInfoBoxData(completion:@escaping ((SCWorkerError?, [SCModelInfoBoxItem]?) -> Void)) {
        
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif

        let infoBoxDataApiPath = "/api/v2/smartcity/infobox"
        let queryDictionary = ["cityId": cityID, "actionName": "GET_InfoBox"] as [String : String]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: infoBoxDataApiPath, parameter: queryDictionary)
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: true) { (response) in
            switch response {
                
            case .success(let fetchedData):
                do {
                    let data = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpModelInfoBoxItem]>.self, from: fetchedData)
                    let items = data.content.map{$0.toModel()}
                    self.infoBoxDataLoadingFailed = false
                    completion(nil, items)
                } catch {
                    debugPrint("SCUserContentSharedWorker->fetchUserData: parsing failed with \(error) for endpoint \(url)")
                    SCFileLogger.shared.write("Harshada -> fetchInfoBoxData | SCUserContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)

                    self.infoBoxDataLoadingFailed = true
                    completion(SCWorkerError.technicalError, nil)
                    SCDataUIEvents.postNotification(for: .infoBoxDataLoadingFailed)
                }
                
            case .failure(let error):
                debugPrint("SCUserContentSharedWorker->fetchUserData: request failed failed with \(error) for endpoint \(url)")
                SCFileLogger.shared.write("Harshada -> fetchInfoBoxData | SCUserContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)

                let workerError = self.mapRequestError(error)
                
                self.infoBoxDataLoadingFailed = true
                completion(self.mapRequestError(error), nil)
                SCDataUIEvents.postNotification(for: .infoBoxDataLoadingFailed, info: workerError)
                
            }
        }
    }

}

