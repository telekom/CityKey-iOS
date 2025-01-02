//
//  SCLocationPresenter.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 19.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCLocationPresenter {

    weak private var display: SCLocationDisplaying?

    private let locationWorker: SCLocationWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private var appContentSharedWorker: SCAppContentSharedWorking
    private let userCityContentSharedWorker: SCUserCityContentSharedWorking
    private let refreshHandler : SCSharedWorkerRefreshHandling
    private let egovServiceWorker: SCEgovServiceWorking
    
    private let injector: SCLocationInjecting & SCLegalInfoInjecting & SCAdjustTrackingInjection

    private var locationService : SCGeoLocation?
    
    private var presentation: [CityLocationInfo]?
    //private var selectedCity: SCModelCity?
    private let widgetUtitly: WidgetUtility
    
    init(locationWorker: SCLocationWorking,
         appContentSharedWorker : SCAppContentSharedWorking,
         cityContentSharedWorker: SCCityContentSharedWorking,
         injector: SCLocationInjecting & SCLegalInfoInjecting & SCAdjustTrackingInjection,
         userCityContentSharedWorker: SCUserCityContentSharedWorking,
         refreshHandler : SCSharedWorkerRefreshHandling,
         widgetUtitly: WidgetUtility = WidgetUtility(),
         egovServiceWorker: SCEgovServiceWorking) {

        self.locationWorker = locationWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.appContentSharedWorker = appContentSharedWorker
        self.injector = injector
        self.userCityContentSharedWorker = userCityContentSharedWorker
        self.refreshHandler = refreshHandler
        self.widgetUtitly = widgetUtitly
        self.egovServiceWorker = egovServiceWorker
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeCityContent, with: #selector(refreshUIContent))

        SCDataUIEvents.registerNotifications(for: self, on: .cityContentLoadingFailed, with: #selector(contentLoadingFailed))
        SCDataUIEvents.registerNotifications(for: self, on: .citiesLoadingFailed, with: #selector(contentLoadingFailed))
        SCDataUIEvents.registerNotifications(for: self, on: .showCityNotAvailable, with: #selector(showCityNotAvailable))

    }
    
    @objc private func contentLoadingFailed() {
        self.display?.hideLocationActivityIndicator()
        self.display?.searchLocActivityIndicator(show: false)
    }

    
    @objc private func refreshUIContent() {
        if !SCUserDefaultsHelper.getCityStatus(){
            if let presentation = self.cityContentSharedWorker.getCities()  {
                let selectedCityContent = self.cityContentSharedWorker.getCityContentData(for: SCUserDefaultsHelper.getDefaultCityId())
                self.updateUI(with: presentation, selectedCity: selectedCityContent?.city)
            }
        }
        else{
            if let presentation = self.cityContentSharedWorker.getCities()  {
                let selectedCityContent = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID())
                self.updateUI(with: presentation, selectedCity: selectedCityContent?.city)
            }
        }
    }
    
    @objc private func showCityNotAvailable() {
        self.display?.showCityNotAvailable()
    }
    
    private func updateUI(with presentation: [CityLocationInfo], selectedCity: SCModelCity?) {
        self.presentation = presentation
        
        self.display?.updateAllCityItems(with: presentation)
        self.display?.updateFavoriteCityItems(with: presentation)
        
        if let city = selectedCity{
            self.display?.showLocationMarker(for: city.name, color: kColor_cityColor)
        }
        
    }
}

// MARK: - SCPresenting
extension SCLocationPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.refreshUIContent()
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
}

// MARK: - SCLocationPresenting
extension SCLocationPresenter: SCLocationPresenting {
    func isStoredLocationSuggestionAvailable() -> Bool {
        self.appContentSharedWorker.isNearestCityAvailable()
    }
    
    func storedLocationSuggestion() -> Int? {
        return self.appContentSharedWorker.storedNearestCity()
    }
    
    func storedDistanceToNearestLocation() -> Double? {
        return self.appContentSharedWorker.storedDistanceToNearestLocation()
    }
    
    
    func setDisplay(_ display: SCLocationDisplaying) {
        self.display = display
    }
    
    func determineLocationButtonWasPressed() {
        self.searchLocation()
    }
    
    func favDidChange(cityName: String, isFavorite: Bool) {
    }
    
    func locationWasSelected(cityName: String, cityID : Int) {
        SCImageLoader.sharedInstance.cancel()
        SCImageCache.clearCache()
        
        // clear all userCity related content
        self.userCityContentSharedWorker.clearData()

        self.cityContentSharedWorker.self.triggerCityContentUpdate(for: cityID, errorBlock: { (error) in
            
            if error != nil {
                switch error {
                case .fetchFailed(let errorDetail):
                    if errorDetail.errorCode == "service.inactive"{
                        SCUserDefaultsHelper.setCityStatus(status: false)
                        self.display?.showCityNotAvailableDialog(retryHandler: {self.loadDefaultCity()}, showCancelButton: false, additionalButtonTitle: nil, additionButtonHandler: nil)
                    }
                    else{
                        let cancelBtnVisibible =  self.cityContentSharedWorker.getCities() == nil ? false : true
                        
                        self.display?.showErrorDialog(error!, retryHandler: {self.locationWasSelected(cityName: cityName, cityID: cityID)}, showCancelButton: cancelBtnVisibible)
                    }
                default:
                    let cancelBtnVisibible =  self.cityContentSharedWorker.getCities() == nil ? false : true
                    
                    self.display?.showErrorDialog(error!, retryHandler: {self.locationWasSelected(cityName: cityName, cityID: cityID)}, showCancelButton: cancelBtnVisibible)
                }
//                let cancelBtnVisibible =  self.cityContentSharedWorker.getCities() == nil ? false : true
//
//                self.display?.showErrorDialog(error!, retryHandler: {self.locationWasSelected(cityName: cityName, cityID: cityID)}, showCancelButton: cancelBtnVisibible)
                return
            }
            self.appContentSharedWorker.firstTimeUsageFinished = true
            
            DispatchQueue.main.async {
                
                if let city = self.cityContentSharedWorker.cityInfo(for: cityID) {
                    
                     // Refresh all other needed data (like appointments,
                     // favorites,...)
                    self.refreshHandler.reloadContent(force: false)
                    self.trackSwitchCityEvent()
                    // prefetch Images
                    SCImageLoader.sharedInstance.getImage(with: city.serviceImageUrl, completion: nil)
                    SCImageLoader.sharedInstance.getImage(with: city.marketplaceImageUrl, completion: nil)
                    
                    SCImageLoader.sharedInstance.getImage(with: city.cityImageUrl, completion: { (_, _) in
                        
                        // After City Image was loaded then we will load the city content. So the image will be
                        // available when when we will dismiss the location controller
                        SCDataUIEvents.postNotification(for: .didChangeLocation)
                        SCUtilities.delay(withTime: 0.0, callback: {
                            self.display?.dismiss()
                        })
                    })
                    
                    //reload widget
                    self.widgetUtitly.reloadAllTimeLines()
                }
            }

        })
    }
    
    //MARK: Add "switchCity" event
    private func trackSwitchCityEvent() {
        var parameters = [String:String]()
        parameters[AnalyticsKeys.TrackedParamKeys.citySelected] = kSelectedCityName
        parameters[AnalyticsKeys.TrackedParamKeys.cityId] = kSelectedCityId
        parameters[AnalyticsKeys.TrackedParamKeys.userStatus] = SCAuth.shared.isUserLoggedIn() ? AnalyticsKeys.TrackedParamKeys.loggedIn : AnalyticsKeys.TrackedParamKeys.notLoggedIn
        if SCAuth.shared.isUserLoggedIn(), let userProfile = SCUserDefaultsHelper.getProfile() {
            parameters[AnalyticsKeys.TrackedParamKeys.userZipcode] = userProfile.postalCode
        }
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.switchCity, parameters: parameters)
    }
    
    func closeButtonWasPressed() {
//        self.display?.dismiss()
        if !SCUserDefaultsHelper.getCityStatus(){
            self.loadDefaultCity()
        }
        else{
            self.display?.dismiss()
        }
        
//        self.display?.dismiss()
    }
    
    func loadDefaultCity(){
        SCUserDefaultsHelper.setCityStatus(status: true)
        self.locationWasSelected(cityName: SCUserDefaultsHelper.getDefaultCityName(), cityID: SCUserDefaultsHelper.getDefaultCityId())
    }
}

extension SCLocationPresenter: SCGeoLocationDelegate {
    
    func searchLocation() {
        self.display?.searchLocActivityIndicator(show: true)
        
        self.locationService = SCGeoLocation()
        self.locationService!.delegate = self
        
        let success = self.locationService!.searchLocation()
        if (!success) {
            self.display?.showLocationFailedMessage(messageTitle:"c_001_cities_dialog_gps_title".localized(), withMessage: "c_001_cities_dialog_gps_message".localized())
            self.locationSearchDidFail()
        }
        
    }
    
    // Delegate methods    
    func locationSearchDidFinish(with latitude: Double, longitute: Double) {
        self.display?.searchLocActivityIndicator(show: false)
        self.locationWorker.fetchCityId(for: latitude, longitude: longitute) { (error, cityId, distance) in
            
            if let cityId = cityId, let distance = distance {
                self.display?.showGeoLocatedCity(for: cityId, distance: distance)
                self.appContentSharedWorker.updateNearestCity(cityId: cityId)
                self.appContentSharedWorker.updateDistanceToNearestLocation(distance: distance)
            } else {
                switch error! {
                case .noInternet:
                    self.display?.showErrorDialog(SCWorkerError.noInternet, retryHandler: { self.locationSearchDidFinish(with: latitude, longitute: longitute)}, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                        
                default:
                    self.display?.showLocationInfoMessage(messageTitle:"c_001_cities_dialog_gps_title".localized(), withMessage: "c_001_cities_dialog_invalid_location_message".localized())
                }
                self.locationSearchDidFail()
            }
        }
    }
    
    func locationSearchDidFail() {
        self.display?.searchLocActivityIndicator(show: false)
        self.display?.configureLocationServiceNotAvailable()
        self.appContentSharedWorker.updateNearestCity(cityId: -1)
        self.appContentSharedWorker.updateDistanceToNearestLocation(distance: -1)
    }
    
    func locationSearchWasDenied() {
        self.display?.searchLocActivityIndicator(show: false)
        self.display?.showLocationFailedMessage(messageTitle:"c_001_cities_dialog_gps_title".localized(), withMessage: "c_001_cities_dialog_gps_message".localized())
        self.display?.configureLocationServiceNotAvailable()
        self.appContentSharedWorker.updateNearestCity(cityId: -1)
        self.appContentSharedWorker.updateDistanceToNearestLocation(distance: -1)
    }
}
