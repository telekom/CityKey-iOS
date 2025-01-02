//
//  FarrhdparkenReportedLocation.swift
//  OSCA
//
//  Created by Bhaskar N S on 08/06/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

protocol FahrradparkenReportedLocationViewDisplay: AnyObject, SCDisplaying {
    func updateNavigationTitle(navTitle: String?)
    func plotMarkersAtReported(locations: [FahrradparkenLocation])
    func present(viewController: UIViewController)
    func dismiss(completion: (() -> Void)?)
    func showBtnActivityIndicator(_ show : Bool)
    func clearAllMarkers()
    func updateMarkerState()
}

protocol FahrradparkenReportedLocationPresenting: SCPresenting {
    var reportedLocations: [FahrradparkenLocation]? { get set }
    func setDisplay(_ display: FahrradparkenReportedLocationViewDisplay)
    func didTapMarker(with location: FahrradparkenLocation)
    func fetchReportedLocations(northEastCoordinate: CLLocationCoordinate2D?, southWestCoordinate: CLLocationCoordinate2D?, limit: Int)
    func getServiceFlow() -> Services
    func savePositionBtnWasPressed()
    func closeButtonWasPressed()
    func getLocationForMap() -> CLLocation
}
