//
//  SCBasicPOIGuideCategorySelectionPresenter.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 26/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import MapKit

class SCBasicPOIGuideCategorySelectionPresenter {

    weak private var display: SCBasicPOIGuideDisplaying?

    private let basicPOIGuideWorker: SCBasicPOIGuideWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let injector: SCToolsInjecting & SCBasicPOIGuideServiceInjecting & SCAdjustTrackingInjection

    private var poiCategory: [POICategoryInfo]?
    private var presentation: [POICategoryInfo]?
    
    private var errorWhileLoading = false
	private let userDefaultsHelper: UserDefaultsHelping

    init(basicPOIGuideWorker: SCBasicPOIGuideWorking, cityContentSharedWorker: SCCityContentSharedWorking,
		 injector: SCToolsInjecting & SCBasicPOIGuideServiceInjecting & SCAdjustTrackingInjection, poiCategory: [POICategoryInfo],
		 userDefaultsHelper: UserDefaultsHelping = UserdefaultHelper()) {

        self.basicPOIGuideWorker = basicPOIGuideWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.injector = injector
        self.poiCategory = poiCategory
        
		self.userDefaultsHelper = userDefaultsHelper
        self.loadCategoryData()
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangePOICategory, with: #selector(refreshUIContent))
    }
    
    @objc private func refreshUIContent() {
        self.poiCategory = self.basicPOIGuideWorker.getCityPOICategories() ?? []
        
        if self.poiCategory?.count == 0 && self.errorWhileLoading {
            self.display?.showOverlayWithGeneralError()
            
        } else if self.poiCategory?.count == 0{
            self.display?.showOverlayWithActivityIndicator()
            
        } else {
            self.display?.hideOverlay()
            
            if let presentation = self.poiCategory  {
                self.updateUI(with: presentation)
            }
        }
    }
    
    private func updateUI(with presentation: [POICategoryInfo]) {
        self.presentation = presentation
        self.display?.updateAllPOICategoryItems(with: presentation)
        self.display?.showPOICategoryMarker(for: SCUserDefaultsHelper.getPOICategory() ?? "", color: kColor_cityColor)
    }
    
    
    private func loadCategoryData(){
        self.basicPOIGuideWorker.triggerPOICategoriesUpdate(for: self.cityContentSharedWorker.getCityID(), errorBlock: { (error) in
            if error != nil {
                if  case .noInternet = error! {
                    self.display?.showErrorDialog(SCWorkerError.noInternet, retryHandler: {self.loadCategoryData()}, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                }
                else{
                    self.display?.showErrorDialog(error!, retryHandler: {self.loadCategoryData()}, showCancelButton: true)
                }
                
                self.errorWhileLoading = true
            }
            self.refreshUIContent()
        })
    }
    
}

// MARK: - SCPresenting
extension SCBasicPOIGuideCategorySelectionPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.display?.setupUI()
        self.refreshUIContent()
    }
    
    func viewWillAppear() {
        self.refreshUIContent()
    }
    
    func viewDidAppear() {
        
    }
}

// MARK: - SCBasicPOIGuidePresenting
extension SCBasicPOIGuideCategorySelectionPresenter: SCBasicPOIGuidePresenting {
    
    func setDisplay(_ display: SCBasicPOIGuideDisplaying){
        self.display = display
    }
    
    func categoryWasSelected(categoryName: String, categoryID: Int, categoryGroupIcon: String){
        
        let cityID = self.cityContentSharedWorker.getCityID()
        
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.changePOICategory)

        self.basicPOIGuideWorker.triggerPOIUpdate(for: cityID, latitude: Double(SCUserDefaultsHelper.getCurrentLocation().coordinate.latitude), longitude: Double(SCUserDefaultsHelper.getCurrentLocation().coordinate.longitude), categoryId: categoryID, errorBlock: { (error) in

            guard error == nil else {
                if  case .noInternet = error! {
                    self.display?.showErrorDialog(SCWorkerError.noInternet, retryHandler: {self.categoryWasSelected(categoryName: categoryName, categoryID: categoryID, categoryGroupIcon: categoryGroupIcon)}, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                }else{
                    self.display?.showErrorDialog(error!, retryHandler: {self.categoryWasSelected(categoryName: categoryName, categoryID: categoryID, categoryGroupIcon: categoryGroupIcon)}, showCancelButton: true)
                }
                return
            }

            DispatchQueue.main.async { [weak self] in
				guard let self = self else { return }

                // available when when we will dismiss the category selection controller
				self.userDefaultsHelper.setPOICategory(poiCategory: categoryName)
				self.userDefaultsHelper.setPOICategoryID(poiCategoryID: categoryID)
				self.userDefaultsHelper.setPOICategoryGroupIcon(poiCategory: categoryGroupIcon)
				self.userDefaultsHelper.setPOIInfo(poiInfo: self.basicPOIGuideWorker.getCityPOI() ?? [])
				self.userDefaultsHelper.setSelectedCityID(id: self.cityContentSharedWorker.getCityID())

                SCDataUIEvents.postNotification(for: .didChangePOI)
                
                SCUtilities.delay(withTime: 0.0, callback: {
                    self.display?.dismiss()
                })
            }

        })
    }
    
    func closeButtonWasPressed(){
        self.display?.dismiss()
    }
    
    func didPressGeneralErrorRetryBtn() {
        self.display?.showOverlayWithActivityIndicator()
        SCUtilities.delay(withTime: 0.3, callback: {
            self.refreshUIContent()
        })
        
    }
}
