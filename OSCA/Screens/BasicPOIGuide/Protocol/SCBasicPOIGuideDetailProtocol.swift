//
//  SCBasicPOIGuideDetailProtocol.swift
//  OSCA
//
//  Created by A106551118 on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCBasicPOIGuideDetailDisplaying: AnyObject, SCDisplaying  {
    func setupUI(navTitle : String,
                 title: String,
                 description: String,
                 address : String,
                 categoryName : String,
                 cityId : Int,
                 distance : Int,
                 icon: SCImageURL?,
                 latitude: Double,
                 longitude: Double,
                 openHours : String,
                 id : Int,
                 subtitle : String,
                 url : String)
    
    func dismiss(completion: (() -> Void)?)
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
}

protocol SCBasicPOIGuideDetailPresenting: SCPresenting {
    func setDisplay(_ display: SCBasicPOIGuideDetailDisplaying)
    func mapViewWasPressed(latitude: Double, longitude: Double, zoomFactor: Float, address: String)
    func directionsButtonWasPressed(latitude : Double, longitude : Double, address: String)
    func reloadDetailPageContent()
    func getShareBarButton() -> UIBarButtonItem?
    func sharePOI()
}
