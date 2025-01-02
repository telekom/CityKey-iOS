//
//  SCEgovSearchPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 18/10/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol SCEgovSearchPresenting : SCPresenting {
    
    func getServiceTitle() -> String
    func setDisplay(_ display: SCEgovSearchDisplay)
    func searchTextChanged(text : String)
    func didSelectResultItemAtIndex(index: Int, object : SCModelEgovService)
    
    func getServiceTitle(service: SCModelEgovService) -> String
    func getServiceDescription(service: SCModelEgovService) -> String
    func getServiceIcon(service: SCModelEgovService) -> UIImage
    func getServiceLinkTitle(service: SCModelEgovService) -> String

}

class SCEgovSearchPresenter {
    
    weak private var display: SCEgovSearchDisplay?
    private let injector: SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection
    private let cityContentSharedWorker : SCCityContentSharedWorking
    private let worker: SCEgovSearchWorking
    private let searchHistoryManager : SCEgovSearchHistoryManaging
    private let serviceDetail: SCServiceDetailProvider
    
    init(injector: SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection,
         cityContentSharedWorker : SCCityContentSharedWorking, worker : SCEgovSearchWorking, searchHistoryManager : SCEgovSearchHistoryManaging, serviceDetail: SCServiceDetailProvider
) {
        
        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
        self.worker = worker
        self.searchHistoryManager = searchHistoryManager
        self.serviceDetail = serviceDetail
        
        self.worker.searchResult.bind { [weak self] searchResult in
            
            if let result = searchResult.result {
                if result.count > 0 { self?.display?.showSearchResult(result: result) }
                else { self?.display?.displayErrorZeroSearchResult(message: self?.formattedZeroResultMessage(searchText: searchResult.searchText) ?? "") }
            }
        }
    }
}

extension SCEgovSearchPresenter : SCEgovSearchPresenting {
    
    
    func viewDidLoad() {
        
        let terms = self.searchHistoryManager.getAllSearchTerms(cityId: "\(self.cityContentSharedWorker.getCityID())")
        if terms.count > 0 { self.display?.showSearchHistoryTerms(terms: terms ) }
        else {self.display?.displayErrorZeroHistoryTerms(message: "egov_search_ftu_msg".localized() ) }
    }

    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
        
    func setDisplay(_ display: SCEgovSearchDisplay) {
        self.display = display
    }
    
    func searchTextChanged(text: String) {
        if text.count > 2 {
            self.worker.searchFor(text: text)
        } else {
            let terms = searchHistoryManager.getAllSearchTerms(cityId: "\(self.cityContentSharedWorker.getCityID())")
            if terms.count > 0 { self.display?.showSearchHistoryTerms(terms: terms ) }
            else { self.display?.displayErrorZeroHistoryTerms(message: "egov_search_ftu_msg".localized()) }
        }
    }
    
    func didSelectResultItemAtIndex(index: Int, object : SCModelEgovService) {
        searchHistoryManager.addSearchTerm(searchTerm: object.serviceName, cityId: "\(self.cityContentSharedWorker.getCityID())")
        
        if !object.longDescription.isEmpty || object.links.count > 1 {
            
            let controller = injector.getEgovServiceLongDescriptionViewController(service: object)
            self.display?.pushViewController(controller)
            
        } else {
            
            guard let link = object.links.first else { return }
            if link.linkType != "eidform" {
                if let urlToOpen = URL(string: link.link), UIApplication.shared.canOpenURL(urlToOpen) {
                    self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openEGovExternalURL)
                    SCInternalBrowser.showURL(urlToOpen, withBrowserType: .safari, title: object.serviceName)
                }
            } else {
                let serviceWebDetails = SCModelEgovServiceWebDetails(serviceTitle: object.serviceName, serviceURL: link.link, serviceType: link.linkType)
                let controller = injector.getAusweisAuthServicesDetailController(for: serviceWebDetails)
                self.display?.pushViewController(controller)
            }
        }
        
    }
    
    func getServiceTitle() -> String {
        return self.serviceDetail.getServiceTitle()
    }
    
    private func formattedZeroResultMessage(searchText: String) -> String {
        return "egov_search_no_results_format".localized().replacingOccurrences(of: "%s", with: searchText)
    }
    
    
    func getServiceTitle(service: SCModelEgovService) -> String {
        return service.serviceName
    }
    
    func getServiceDescription(service: SCModelEgovService) -> String {
        return service.shortDescription
    }
    
    func getServiceIcon(service: SCModelEgovService) -> UIImage {
        
        if !service.longDescription.isEmpty || service.links.count > 1  {
            return UIImage(named: "eGov_Service_MoreInfo_Icon" )!
        }
        
        guard let linkType = service.links.first?.linkType else {
            return UIImage(named: "eGov_Service_MoreInfo_Icon" )!
        }
        
        if let imageName =
            ["eidform" : "eGov_Service_Eid_Icon",
             "form": "eGov_Service_Form_Icon",
             "pdf": "eGov_Service_Pdf_Icon",
             "web": "eGov_Service_Website_Icon"][linkType] {
            
            return UIImage(named: imageName)!
            
        } else {
            return UIImage(named: "eGov_Service_Website_Icon")!
        }
        
    }
    
   
    
    func getServiceLinkTitle(service: SCModelEgovService) -> String {
        
        if !service.longDescription.isEmpty || service.links.count > 1 {
            return "apnmt_002_more_info_button".localized()
        }
        
        if let linkTitle = service.links.first?.title {
            if !linkTitle.isEmpty { return linkTitle }
        }
        
        guard let linkType = service.links.first?.linkType else { return "" }
        
        switch linkType {
        case "eidform":
            return "egovs_002_services_type_form_eid".localized()
        case "pdf":
            return "egovs_002_services_type_pdf".localized()
        case "form":
            return "egovs_002_services_type_form".localized()
        case "web":
            return "egovs_002_services_type_web".localized()
        default:
            return "egovs_002_services_type_web".localized()
        }
    }
}




