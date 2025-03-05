/*
Created by Harshada Deshmukh on 26/02/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation

protocol SCBasicPOIGuideWorking {
    var poiDataState: SCWorkerDataState { get }
    var poiCategoryDataState: SCWorkerDataState { get }

    func getCityPOI(cityId: String, latitude: Double, longitude: Double, categoryId: String,
                           completion: @escaping (([SCModelPOI], SCWorkerError?) -> Void))
    func getCityPOICategories(cityId: String, completion: @escaping ([SCModelPOICategory], SCWorkerError?) -> Void)
    func getCityPOICount(cityId: String, categoryId: String, completion: @escaping (Int, SCWorkerError?) -> Void)
    func getCityPOICategories() -> [POICategoryInfo]?
    func getCityPOI() -> [POIInfo]?
    func triggerPOICategoriesUpdate(for cityID: Int, errorBlock: @escaping (SCWorkerError?)->())
    func triggerPOIUpdate(for cityID: Int, latitude: Double, longitude: Double, categoryId: Int, errorBlock: @escaping (SCWorkerError?)->())
    
}

class SCBasicPOIGuideWorker: SCWorker {
    private var poi : [SCModelPOI]?
    private var poiCategories : [SCModelPOICategory]?

    private let poiPath = "/api/v2/smartcity/poi"
    var poiDataState = SCWorkerDataState(dataInitialized: false, dataLoadingState: .needsToBefetched)
    var poiCategoryDataState = SCWorkerDataState(dataInitialized: false, dataLoadingState: .needsToBefetched)

}

extension SCBasicPOIGuideWorker: SCBasicPOIGuideWorking {

    func getCityPOI(cityId: String, latitude: Double, longitude: Double, categoryId: String, completion: @escaping (([SCModelPOI], SCWorkerError?) -> Void)) {

        let queryParameter = ["cityId": cityId, "actionName": "GET_CityPOI", "lat": String(latitude), "lng": String(longitude), "categoryId": categoryId]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: poiPath, parameter: queryParameter)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in

            switch result {
            case .success(let response):
                do {
                    let poi = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpModelPOI]>.self, from: response)
                    let poiContent = poi.content.map {$0.toModel()}
                    self.poi = poiContent

                    completion(poiContent, nil)
                } catch {
                    self.poiDataState.dataLoadingState = .fetchFailed
                    completion([], .technicalError)
                }

            case .failure(let error):
                self.poiDataState.dataLoadingState = .fetchFailed
                completion([], self.mapRequestError(error))
            }
        }
    }

    func getCityPOICategories(cityId: String, completion: @escaping (([SCModelPOICategory], SCWorkerError?) -> Void)) {
       
        self.poiCategoryDataState.dataLoadingState = .fetchingInProgress

        let queryParameter = ["cityId": cityId, "actionName": "GET_CityPOICategories"]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: poiPath, parameter: queryParameter)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in

            switch result {
            case .success(let response):
                do {
                    let poi = try JSONDecoder().decode(SCHttpModelResponse<[SCHttpModelPOICategory]>.self, from: response)
                    let poiContent = poi.content.map {$0.toModel()}
                    self.poiCategories = poiContent
                    self.poiCategoryDataState.dataInitialized = true
                    self.poiCategoryDataState.dataLoadingState = .fetchedWithSuccess

                    completion(poiContent, nil)
                } catch {
                    self.poiCategoryDataState.dataLoadingState = .fetchFailed
                    completion([], .technicalError)
                }

            case .failure(let error):
                self.poiCategoryDataState.dataLoadingState = .fetchFailed
                completion([], self.mapRequestError(error))
            }
        }
    }
    
    func getCityPOICount(cityId: String, categoryId: String, completion: @escaping ((Int, SCWorkerError?) -> Void)) {

        let queryParameter = ["cityId": cityId, "actionName": "GET_CityPOICount", "categoryId": categoryId]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: poiPath, parameter: queryParameter)

        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (result) in

            switch result {
            case .success(let response):
                do {
                    let poi = try JSONDecoder().decode(SCHttpModelResponse<Int>.self, from: response)
                    completion(poi.content, nil)
                } catch {
                    completion(0, .technicalError)
                }

            case .failure(let error):
                completion(-1, self.mapRequestError(error))
            }
        }
    }
    
    func getCityPOICategories() -> [POICategoryInfo]? {
        guard let poiCategories = self.poiCategories else {
            return nil
        }
        var categories = [POICategoryInfo]()
        
        for poiCategory in poiCategories {
            categories.append(POICategoryInfo(categoryGroupIcon: poiCategory.categoryGroupIcon, categoryGroupId: poiCategory.categoryGroupId, categoryGroupName: poiCategory.categoryGroupName, categoryList: poiCategory.categoryList, categoryFavorite: false))
        }
        
//        return categories.sorted {
//            $0.categoryGroupName < $1.categoryGroupName
//        }
        
        return categories

    }
    
    func triggerPOICategoriesUpdate(for cityID: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
        
        guard self.poiCategoryDataState.dataLoadingState != .fetchingInProgress else {
            SCUtilities.delay(withTime: 0.0, callback: {errorBlock(nil)})
            return
        }
        
        self.poiCategoryDataState.dataLoadingState = .fetchingInProgress
        
        self.getCityPOICategories(cityId: String(cityID)) { (poiCategories, error) in
            guard error == nil else {
                self.poiCategoryDataState.dataLoadingState = .fetchFailed
                errorBlock(error)
                return
            }
            self.poiCategoryDataState.dataInitialized = true
            self.poiCategoryDataState.dataLoadingState = .fetchedWithSuccess

            SCUtilities.delay(withTime: 0.0, callback: {
                SCDataUIEvents.postNotification(for: .didChangePOICategory)
                errorBlock(nil) // this is ONLY for the appDelegate/Injector case, needs to be rethought
            })
        }
    }
    
    func getCityPOI() -> [POIInfo]? {
        guard let poiInfo = self.poi else {
            return nil
        }
        var pois = [POIInfo]()
        
        for poi in poiInfo {
            pois.append(POIInfo(address: poi.address, categoryName: poi.categoryName, cityId: poi.cityId, description: poi.description, distance: poi.distance, icon: poi.icon, id: poi.id, latitude: poi.latitude, longitude: poi.longitude, openHours: poi.openHours, subtitle: poi.subtitle, title: poi.title, url: poi.url, poiFavorite: false))
        }
        
//        return pois.sorted {
//            $0.categoryName < $1.categoryName
//        }
        
        return pois

    }
    
    func triggerPOIUpdate(for cityID: Int, latitude: Double, longitude: Double, categoryId: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
        
        guard self.poiDataState.dataLoadingState != .fetchingInProgress else {
            SCUtilities.delay(withTime: 0.0, callback: {errorBlock(nil)})
            return
        }
        
        self.poiDataState.dataLoadingState = .fetchingInProgress
        
        self.getCityPOI(cityId: String(cityID), latitude: latitude, longitude: longitude, categoryId: String(categoryId)) { (poi, error) in
            guard error == nil else {
                self.poiDataState.dataLoadingState = .fetchFailed
                errorBlock(error)
                return
            }
            self.poiDataState.dataInitialized = true
            self.poiDataState.dataLoadingState = .fetchedWithSuccess

            SCUtilities.delay(withTime: 0.0, callback: {
                SCDataUIEvents.postNotification(for: .didChangePOI)
                errorBlock(nil) // this is ONLY for the appDelegate/Injector case, needs to be rethought
            })
        }
    }
}
