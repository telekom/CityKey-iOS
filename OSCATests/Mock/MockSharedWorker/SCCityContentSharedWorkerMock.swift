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
*///
//  SCCityContentSharedWorkerMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 13/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import CoreLocation
@testable import OSCA

class SCCityContentSharedWorkerMock: SCCityContentSharedWorking {
    var citiesDataState = SCWorkerDataState()
    var cityContentDataState = SCWorkerDataState()
    var newsDataState = SCWorkerDataState()
    var servicesDataState = SCWorkerDataState()
    var weatherDataState = SCWorkerDataState()
    
    func getCities() -> [CityLocationInfo]? {
        return nil
    }
    
    func triggerCitiesUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {

    }
    
    func isCityContentAvailable(for cityID: Int) -> Bool {
        false
    }
    
    func getNews(for cityID: Int) -> [SCModelMessage]? {
        [SCModelMessage(id: "", title: "", shortText: "", subtitleText: "", detailText: "", contentURL: nil,
                        imageURL: nil, imageCredit: nil, thumbnailURL: nil, type: .news, date: Date(), sticky: false),
         SCModelMessage(id: "", title: "", shortText: "", subtitleText: "", detailText: "", contentURL: nil,
                         imageURL: nil, imageCredit: nil, thumbnailURL: nil, type: .news, date: Date(), sticky: false)]
    }
    
    func getServices(for cityID: Int) -> [SCModelServiceCategory]? {
        [SCModelServiceCategory]()
    }
    
    func getWeather(for cityID: Int) -> String {
        ""
    }
    
    func getCityContentData(for cityID: Int) -> SCCityContentModel? {
        return SCCityContentModel(city: SCModelCity(cityID: 13, name: "Bad Honnef", cityTintColor: .blue,
                                                    stateName: "", country: "", cityImageUrl: SCImageURL(urlString: "", persistence: false),
                                                    cityPreviewImageUrl: SCImageURL(urlString: "", persistence: false),
                                                    serviceImageUrl: SCImageURL(urlString: "", persistence: false),
                                                    marketplaceImageUrl: SCImageURL(urlString: "", persistence: false),
                                                    municipalCoatImageUrl: SCImageURL(urlString: "", persistence: false), postalCode: []),
                                  cityImprint: "test.com",
                                  cityConfig: SCModelCityConfig(showFavouriteServices: false, showHomeDiscounts: false, showHomeOffers: false, showHomeTips: false, showFavouriteMarketplaces: false, showNewServices: false, showNewMarketplaces: false, showMostUsedServices: false, showMostUsedMarketplaces: false, showCategories: false, showBranches: false, showDiscounts: false, showOurMarketPlaces: false, showOurServices: false, showMarketplacesOption: false, showServicesOption: false, stickyNewsCount: 1),
                                  cityImprintDesc: "test cityImprintDesc",
                                  cityServiceDesc: "", cityNightPicture: nil, imprintImageUrl: nil)
    }
    
    func triggerCityContentUpdate(for cityID: Int, errorBlock: @escaping (SCWorkerError?) -> ()) {
        
    }
    
    func cityInfo(for cityID: Int) -> SCModelCity? {
        nil
    }
    
    func cityIDForPostalCode(postalcode: String) -> Int? {
        nil
    }
    
    func setStoredCityID(for cityID: Int) {
        
    }
    
    func setStoredCityLocation(for cityLocation: CLLocation) {
        
    }
    
    func getServiceMoreInfoHTMLText(cityId: String, serviceId: String, completion: @escaping (String, SCWorkerError?) -> Void) {
        
    }
    
    func checkIfDayOrNightTime() -> SCSunriseOrSunset {
        SCSunriseOrSunset.sunrise
    }
    
    func getCityID() -> Int {
        return 13
    }
    
    func getCityLocation() -> CLLocation {
        return CLLocation(latitude: 1.0987, longitude: 1.0987)
    }
    
    func updateSelectedCityIdIfNotFoundInCitiesList(errorBlock: ((SCWorkerError?) -> ())?) {
        errorBlock?(nil)
    }
}
