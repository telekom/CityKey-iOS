//
//  FahrradparkenReportedLocationDetailPresenter.swift
//  OSCA
//
//  Created by Bhaskar N S on 22/05/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

class FahrradparkenReportedLocationDetailPresenter: FahrradparkenReportedLocationDetailPresenting {
    weak private var display: FahrradparkenReportedLocationDetailViewDisplay?
    var reportedLocation: FahrradparkenLocation
    var completionHandler: (() -> Void)?
    private let serviceData: SCBaseComponentItem
    
    init(reportedLocation: FahrradparkenLocation, serviceData: SCBaseComponentItem, completionHandler: (() -> Void)?) {
        self.reportedLocation = reportedLocation
        self.serviceData = serviceData
        self.completionHandler = completionHandler
    }
    
    func setDisplay(_ display: FahrradparkenReportedLocationDetailViewDisplay) {
        self.display = display
    }
    
    func viewDidLoad() {
        display?.setupUI()
    }
    
    func getMainCategoryTitle() -> String? {
        return serviceData.itemCategoryTitle
    }
    
    func getMoreInformationUrl() -> String? {
        let serviceParamsInfo = serviceData.itemServiceParams
        let emailParam = serviceParamsInfo?["field_moreInformationBaseURL"] ?? ""
        return emailParam + "/requests/\(reportedLocation.serviceRequestID ?? "")"
    }
    
    func handleCompletion() {
        completionHandler?()
    }
}
