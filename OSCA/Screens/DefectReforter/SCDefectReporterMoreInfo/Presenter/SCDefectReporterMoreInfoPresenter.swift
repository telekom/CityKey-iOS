//
//  SCDefectReporterMoreInfoPresenter.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 07/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCDefectReporterMoreInfoPresenter {
    
    weak private var display: SCDefectReporterMoreInfoViewDisplay?
    private let injector: SCServicesInjecting

    init( injector: SCServicesInjecting ) {
        
        self.injector = injector
    }
}

extension SCDefectReporterMoreInfoPresenter : SCDefectReporterMoreInfoPresenting {
    func setDisplay(_ display : SCDefectReporterMoreInfoViewDisplay) {
        self.display = display
    }
}
