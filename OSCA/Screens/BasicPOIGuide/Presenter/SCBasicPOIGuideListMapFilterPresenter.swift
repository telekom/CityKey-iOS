//
//  SCBasicPOIGuideListMapFilterPresenter.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 26/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import MapKit
import TTGSnackbar

class SCBasicPOIGuideListMapFilterPresenter {
    
    weak private var display: SCBasicPOIGuideListMapFilterDisplaying?
    
    private let injector: SCAdjustTrackingInjection & SCBasicPOIGuideServiceInjecting & SCDisplayBasicPOIGuideInjecting
    private var poiCategory: [POICategoryInfo]
    private var poi: [POIInfo]?

    private let basicPOIGuideWorker: SCBasicPOIGuideWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let cityID : Int
    private let item: SCBaseComponentItem
	private let userDefaults: UserDefaultsHelping

    private var errorWhileLoading = false

    init(cityID: Int, poi: [POIInfo], poiCategory: [POICategoryInfo], 
		 injector: SCAdjustTrackingInjection & SCBasicPOIGuideServiceInjecting & SCDisplayBasicPOIGuideInjecting,
		 basicPOIGuideWorker: SCBasicPOIGuideWorking,
		 cityContentSharedWorker: SCCityContentSharedWorking,
		 item: SCBaseComponentItem,
		 userDefaults: UserDefaultsHelping = UserdefaultHelper()) {

        self.poi = poi
        self.poiCategory = poiCategory
        self.injector = injector
        self.basicPOIGuideWorker = basicPOIGuideWorker
        self.cityID = cityID
        self.cityContentSharedWorker = cityContentSharedWorker
        self.item = item
		self.userDefaults = userDefaults
        
        self.setupNotifications()
        self.loadPOIData()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangePOI, with: #selector(refreshUIContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didUpdatePOICategory, with: #selector(didUpdatePOICategory))
    }
        
    @objc private func refreshUIContent() {

        self.poi = userDefaults.getPOIInfo() ?? []

        if userDefaults.getPOICategory() == nil {
            return
        }
        self.display?.updateCategory()
        
        if self.poi?.count == 0 && self.errorWhileLoading {
            self.display?.showOverlayWithGeneralError()
            
        } else if self.poi?.count == 0{
            self.display?.showOverlayWithActivityIndicator()
        }
        else{
            self.display?.hideOverlay()
            self.display?.loadPois(self.poi!)
        }
    }
    
    @objc private func didUpdatePOICategory(){
        display?.updateCategory()
    }

    private func loadPOIData() {
        
        // Bugfix for SMARTC-17662 - Client: POI data fails to load in some cases
        
        if userDefaults.getSelectedCityID() != 0 &&
			userDefaults.getSelectedCityID() != self.cityContentSharedWorker.getCityID(){
            UserDefaults.standard.removeObject(forKey: GlobalConstants.poiCategoryNameKey)
            self.display?.updateCategory()
            self.loadCategoryData()
            return
        }
        
        if !CLLocationManager.locationServicesEnabled(){
            self.loadCategoryData()
            return
        }
		let location = userDefaults.getCurrentLocation()
        self.basicPOIGuideWorker.triggerPOIUpdate(for: self.cityContentSharedWorker.getCityID(),
												  latitude: Double(location.coordinate.latitude),
												  longitude: Double(location.coordinate.longitude),
												  categoryId: userDefaults.getPOICategoryID() ?? -1,
												  errorBlock: { (error) in
            if error != nil {
                if  case .noInternet = error! {
                    self.display?.showErrorDialog(SCWorkerError.noInternet, retryHandler: {self.loadPOIData()}, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                }
//                else{
//                    self.display?.showErrorDialog(error!, retryHandler: {self.loadPOIData()}, showCancelButton: true)
//                }
                self.errorWhileLoading = true

            }
			self.userDefaults.setPOIInfo(poiInfo: self.basicPOIGuideWorker.getCityPOI() ?? [])
            self.refreshUIContent()
            
        })
    }
    
    // Bugfix for SMARTC-17662 - Client: POI data fails to load in some cases
    func updateCategoryIdForCity(){
        self.poiCategory = self.basicPOIGuideWorker.getCityPOICategories() ?? []
        
        for category in self.poiCategory{
            
            let result = category.categoryList.filter({$0.categoryName == userDefaults.getSelectedPOICategory()?.categoryName})
            if result.count != 0 {
				userDefaults.setPOICategoryID(poiCategoryID: result.first?.categoryId ?? -1)
                break
            }
        }
    }
    
    private func loadCategoryData(){
        self.basicPOIGuideWorker.triggerPOICategoriesUpdate(for: self.cityContentSharedWorker.getCityID(), errorBlock: { (error) in
            if error != nil {
                if  case .noInternet = error! {
                    self.display?.showErrorDialog(SCWorkerError.noInternet, retryHandler: {self.loadCategoryData()}, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                }
                else{
                }
                
            }
            let categoryViewController = self.injector.getBasicPOIGuideCategoryViewController(with: self.basicPOIGuideWorker.getCityPOICategories() ?? [], includeNavController: true, completionAfterDismiss: nil)
            self.display?.present(viewController: categoryViewController)

        })
    }
}

extension SCBasicPOIGuideListMapFilterPresenter: SCPresenting {
    func viewDidLoad() {
        self.refreshUIContent()
        self.display?.setupUI(with: item.itemTitle)
    }
    
    func viewWillAppear() {
    }
    
    func viewDidAppear() {
    }
}

extension SCBasicPOIGuideListMapFilterPresenter : SCBasicPOIGuideListMapFilterPresenting {
    
    func setDisplay(_ display: SCBasicPOIGuideListMapFilterDisplaying) {
        self.display = display
    }

    func didSelectListItem(item: POIInfo) {
        let viewController = self.injector.getBasicPOIGuideDetailController(with: item)
        self.display?.push(viewController: viewController)
    }

    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
    func closePOIOverlayButtonWasPressed() {
        self.display?.hidePOIOverlay()
    }
    
    func categoryWasPressed(){
        let categoryViewController = self.injector.getBasicPOIGuideCategoryViewController(with: self.basicPOIGuideWorker.getCityPOICategories() ?? [], includeNavController: true, completionAfterDismiss: nil)
        self.display?.present(viewController: categoryViewController)
    }
    
    func didPressGeneralErrorRetryBtn() {
        self.display?.showOverlayWithActivityIndicator()
        SCUtilities.delay(withTime: 0.3, callback: {
            self.loadPOIData()
        })
    }
    
    func getCityLocation() -> CLLocation {
        return self.cityContentSharedWorker.getCityLocation()
    }
    
}
