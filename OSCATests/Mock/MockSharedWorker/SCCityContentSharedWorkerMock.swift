//
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
