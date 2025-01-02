//
//  SCEgovServiceLongDescriptionPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 08/11/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol SCEgovServiceLongDescriptionPresenting : SCPresenting {

    func setDisplay(_ display : SCEgovServiceLongDescriptionDisplay)
    func getTitle() -> String
    func getServiceIcon(link: SCModelEgovServiceLink) -> UIImage
    func getServiceLinkTitle(link: SCModelEgovServiceLink) -> String
    func didSelectLink(link: SCModelEgovServiceLink)
}

class SCEgovServiceLongDescriptionPresenter {
    
    weak var display : SCEgovServiceLongDescriptionDisplay?
    var service: SCModelEgovService
    var injector : SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection
    
    init(service : SCModelEgovService, injector: SCEgovServiceInjecting & SCServicesInjecting & SCAdjustTrackingInjection) {
        self.service = service
        self.injector = injector
    }
}

extension SCEgovServiceLongDescriptionPresenter : SCEgovServiceLongDescriptionPresenting {
    
    func viewDidLoad() {
        
        if let attrString =  service.longDescription.htmlAttributedString?.trimmedAttributedString(set: .whitespacesAndNewlines) {
            let htmlAttributedString = NSMutableAttributedString(attributedString: attrString)
            htmlAttributedString.replaceFont(with: UIFont.systemFont(ofSize: (UIScreen.main.bounds.size.width) == 320 ? 14.0 : 16.0, weight: UIFont.Weight.medium), color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
            display?.setHtmlDescription(text: htmlAttributedString)
        }
        display?.setServiceLinks(service.links)
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
        
    func setDisplay(_ display : SCEgovServiceLongDescriptionDisplay) {
        self.display = display
    }
    
    func getTitle() -> String {
        return service.serviceName
    }
    
    func getServiceIcon(link: SCModelEgovServiceLink) -> UIImage {
        
        if let imageName =
            ["eidform" : "eGov_Service_Eid_Icon",
             "form": "eGov_Service_Form_Icon",
             "pdf": "eGov_Service_Pdf_Icon",
             "web": "eGov_Service_Website_Icon"][link.linkType] {
            
            return UIImage(named: imageName)!
            
        } else {
            return UIImage(named: "eGov_Service_Website_Icon")!
        }
        
    }
    
    func getServiceLinkTitle(link: SCModelEgovServiceLink) -> String {
       
        if !link.title.isEmpty { return link.title }
       
        switch link.linkType {
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

    func didSelectLink(link: SCModelEgovServiceLink) {
        if link.linkType != "eidform" {
            if let urlToOpen = URL(string: link.link), UIApplication.shared.canOpenURL(urlToOpen) {
                self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openEGovExternalURL)
                SCInternalBrowser.showURL(urlToOpen, withBrowserType: .safari, title: service.serviceName)
            }
        } else {
            let serviceWebDetails = SCModelEgovServiceWebDetails(serviceTitle: service.serviceName, serviceURL: link.link, serviceType: link.linkType)
            let controller = injector.getAusweisAuthServicesDetailController(for: serviceWebDetails)
            self.display?.pushViewController(controller)
        }
        
    }
}
