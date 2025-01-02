//
//  SCServicesMoreInfoViewPresenter.swift
//  OSCA
//
//  Created by A118572539 on 16/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCServicesMoreInfoViewPresenting : SCPresenting {
    func setDisplay(_ display : SCServicesMoreInfoViewDisplay)
    func reloadWebView()
}

class SCServicesMoreInfoViewPresenter {
    
    weak private var display: SCServicesMoreInfoViewDisplay?
  //  private let worker: SCServicesWorker
    private let injector: SCServicesInjecting
    private let cityContentSharedWorker : SCCityContentSharedWorking
    private let serviceDetails: SCServiceDetailProvider
    private var helpHtmlContent: String = ""
    
    init(injector : SCServicesInjecting,
         serviceDetails: SCServiceDetailProvider,
         cityContentSharedWorker : SCCityContentSharedWorking ) {
        
      //  self.worker = worker
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
                self?.helpHtmlContent = helpHTMLContent
                self?.display?.loadHTMLContent(helpHTMLContent)
            }
        }
    }
}

extension SCServicesMoreInfoViewPresenter : SCServicesMoreInfoViewPresenting {
    
    func viewDidLoad() {
        display?.setNavigationTitle(serviceDetails.getServiceTitle())
        loadHelpContent()
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func setDisplay(_ display : SCServicesMoreInfoViewDisplay) {
        self.display = display
    }
    
    func reloadWebView() {
        display?.loadHTMLContent(helpHtmlContent)
    }
}


