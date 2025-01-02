//
//  WidgetHelper.swift
//  OSCA
//
//  Created by A200111500 on 29/04/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

public struct WidgetHelper {
    private let cityContentSharedWorker: SCCityContentSharedWorking
    
    init(cityContentSharedWorker: SCCityContentSharedWorking = SCCityContentSharedWorker(requestFactory: SCRequest())) {
        self.cityContentSharedWorker = cityContentSharedWorker
    }
    
    func fetchCities() {
        
    }
}
