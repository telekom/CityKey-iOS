//
//  SCEgovServiceHelpPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 01/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCEgovServiceHelpPresenting : SCPresenting {
    func setDisplay(_ display : SCEgovServiceHelpViewDisplay)
    func reloadHelpHTMLContent()
}

class SCEgovServiceHelpPresenter {
    
    weak private var display: SCEgovServiceHelpViewDisplay?
    private let worker: SCEgovServiceWorking
    private let injector: SCEgovServiceInjecting & SCServicesInjecting
    private let cityContentSharedWorker : SCCityContentSharedWorking
    private let serviceDetails: SCServiceDetailProvider
    private var helpHTMLContent: String?
    
    init(worker : SCEgovServiceWorking,
         injector : SCEgovServiceInjecting & SCServicesInjecting,
         serviceDetails: SCServiceDetailProvider,
         cityContentSharedWorker : SCCityContentSharedWorking ) {
        
        self.worker = worker
        self.injector = injector
        self.serviceDetails = serviceDetails
        self.cityContentSharedWorker = cityContentSharedWorker
    }
    
    private func loadHelpContent() {
        cityContentSharedWorker.getServiceMoreInfoHTMLText(cityId: "\(cityContentSharedWorker.getCityID())", serviceId: serviceDetails.getServiceID()) { [weak self] (helpHTMLContent, error) in
            if let error = error {
                self?.display?.showErrorDialog(error, retryHandler: {
                    self?.loadHelpContent()
                }, showCancelButton: true)
            } else {
                self?.helpHTMLContent = helpHTMLContent
                self?.display?.loadHTMLContent(helpHTMLContent)
            }
        }
    }
}

extension SCEgovServiceHelpPresenter : SCEgovServiceHelpPresenting {
    
    func viewDidLoad() {
        
        display?.setNavigationTitle(serviceDetails.getServiceTitle())
        loadHelpContent()
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
         
    func setDisplay(_ display : SCEgovServiceHelpViewDisplay) {
        self.display = display
    }
    
    func reloadHelpHTMLContent() {
        if let helpHTMLContent = helpHTMLContent {
            display?.loadHTMLContent(helpHTMLContent)
        }
    }
}
