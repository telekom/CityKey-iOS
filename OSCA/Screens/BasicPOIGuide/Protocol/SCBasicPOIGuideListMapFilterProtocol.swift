//
//  SCBasicPOIGuideListMapFilterProtocol.swift
//  OSCA
//
//  Created by A106551118 on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import CoreLocation

protocol SCBasicPOIGuideListMapFilterDisplaying: AnyObject, SCDisplaying  {
    
    func updateCategory()
    func loadPois(_ poiItems: [POIInfo])
    func dismiss(completion: (() -> Void)?)
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func showPOIOverlay()
    func hidePOIOverlay()
    func showLocationFailedMessage(messageTitle: String, withMessage: String)
    func showOverlayWithActivityIndicator()
    func showOverlayWithGeneralError()
    func hideOverlay()
    func setupUI(with navigationTitle: String)
}

protocol SCBasicPOIGuideListMapFilterPresenting: SCPresenting {
    func setDisplay(_ display: SCBasicPOIGuideListMapFilterDisplaying)
    func didSelectListItem(item: POIInfo)
    func closeButtonWasPressed()
    func categoryWasPressed()
    func closePOIOverlayButtonWasPressed()
    func didPressGeneralErrorRetryBtn()
    func getCityLocation() -> CLLocation

}

