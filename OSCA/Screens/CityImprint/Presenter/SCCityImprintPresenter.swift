//
//  CityImprintPresenter.swift
//  OSCA
//
//  Created by Michael on 20.06.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCCityImprintDisplaying: AnyObject, SCDisplaying {
    func setupUI()
    func updateCityName(_ cityName : String)
    func updateCityImage(withURL: SCImageURL?)
    func updateImprintDesc(_ imprintDesc : String?)
    func handleAppPreviewBannerView()
    func updateImprintImage(withUrl: SCImageURL?)
}

protocol SCCityImprintPresenting: SCPresenting {
    func setDisplay(_ display: SCCityImprintDisplaying)
        
    func locationButtonWasPressed()
    func profileButtonWasPressed()
    func imprintButtonWasPressed()
}

class SCCityImprintPresenter {

    weak private var display: SCCityImprintDisplaying?

    private let injector: SCToolsShowing
    private let cityContentSharedWorker: SCCityContentSharedWorking
    
    init(cityContentSharedWorker: SCCityContentSharedWorking, injector: SCToolsShowing) {

        self.cityContentSharedWorker = cityContentSharedWorker
        self.injector = injector
        self.setupNotifications()
    }

    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }

    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeLocation, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeCityContent, with: #selector(didChangeContent))
        SCDataUIEvents.registerNotifications(for: self, on: .didUpdateAppPreviewMode, with: #selector(handleAppPreviewModeChange))
    }
    
    @objc private func handleAppPreviewModeChange() {
        self.display?.handleAppPreviewBannerView()
    }

    @objc private func didChangeContent() {
        self.refreshUIContent()
    }
    
    @objc private func didChangeLocation() {
         self.refreshUIContent()
    }

    private func refreshUIContent() {
        if let contentModel = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID()) {
            self.display?.updateCityName(contentModel.city.name)
            display?.updateCityImage(withURL: contentModel.city.municipalCoatImageUrl)
            self.display?.updateImprintDesc(contentModel.cityImprintDesc)
            display?.updateImprintImage(withUrl: contentModel.imprintImageUrl)
        } else {
            display?.updateCityImage(withURL: nil)
            display?.updateImprintImage(withUrl: nil)
        }
    }
}

// MARK: - SCPresenting

extension SCCityImprintPresenter: SCPresenting {
    func viewDidLoad() {
        self.display?.setupUI()
        self.refreshUIContent()

    }
}

// MARK: - SCServicesPresenting

extension SCCityImprintPresenter: SCCityImprintPresenting {
    
    func setDisplay(_ display: SCCityImprintDisplaying) {
        self.display = display
    }

    func locationButtonWasPressed() {
        self.injector.showLocationSelector()
    }
     
    func profileButtonWasPressed() {
        self.injector.showProfile()
    }

    func imprintButtonWasPressed() {
        if let cityImprintLink = self.cityContentSharedWorker.getCityContentData(for: self.cityContentSharedWorker.getCityID())?.cityImprint,
            let urlToOpen = URL(string: cityImprintLink),
            UIApplication.shared.canOpenURL(urlToOpen) {
                SCInternalBrowser.showURL(urlToOpen, withBrowserType: .safari)
        }
    }

    
}
