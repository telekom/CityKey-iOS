//
//  SCDefectReporterLocationProtocol.swift
//  OSCA
//
//  Created by Bhaskar N S on 22/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import MapKit

protocol SCDefectReporterLocationViewDisplay: AnyObject, SCDisplaying {
    
    func dismiss(completion: (() -> Void)?)
    func push(viewController: UIViewController)
    func showLocationFailedMessage(messageTitle: String, withMessage: String)
    func reloadDefectLocationMap(location: CLLocation)

}

protocol SCDefectReporterLocationPresenting: SCPresenting {
    func setDisplay(_ display: SCDefectReporterLocationViewDisplay)
    func closeButtonWasPressed()
    func savePositionBtnWasPressed()
    var serviceFlow: Services { get set }

}


