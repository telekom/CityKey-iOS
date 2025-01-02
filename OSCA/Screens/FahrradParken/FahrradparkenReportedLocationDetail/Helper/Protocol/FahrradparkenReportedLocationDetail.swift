//
//  FahrradparkenLocationDetails.swift
//  OSCA
//
//  Created by Bhaskar N S on 08/06/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol FahrradparkenReportedLocationDetailViewDisplay: AnyObject, SCDisplaying {
    func setupUI()
}

protocol FahrradparkenReportedLocationDetailPresenting: SCPresenting {
    var reportedLocation: FahrradparkenLocation { get set }
    func setDisplay(_ display: FahrradparkenReportedLocationDetailViewDisplay)
    func getMainCategoryTitle() -> String?
    func getMoreInformationUrl() -> String?
    func handleCompletion()
}
