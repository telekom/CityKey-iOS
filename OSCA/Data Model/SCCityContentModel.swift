//
//  SCCityContentModel.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 20.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCCityContentModel {
    let city: SCModelCity
    let cityImprint: String?
    let cityConfig: SCModelCityConfig
    let cityImprintDesc: String?
    let cityServiceDesc: String?
    let cityNightPicture: SCImageURL?
    let imprintImageUrl: SCImageURL?
}
