//
//  SCBasicPOIGuideListMapFilterViewController+CLLocationManagerDelegate.swift
//  OSCA
//
//  Created by A106551118 on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import CoreLocation

// MARK: - CLLocationManagerDelegate
// Delegates to handle events for the location manager.
extension SCBasicPOIGuideListMapFilterViewController: CLLocationManagerDelegate {

    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        SCUserDefaultsHelper.setCurrentLocation(location)
        
        //Finally stop updating location otherwise it will come again and again in this delegate
        self.locationManager.stopUpdatingLocation()
    }

    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Check accuracy authorization
        if #available(iOS 14.0, *) {
            let accuracy = manager.accuracyAuthorization
            switch accuracy {
            case .fullAccuracy:
                debugPrint("Location accuracy is precise.")
            case .reducedAccuracy:
                debugPrint("Location accuracy is not precise.")
            @unknown default:
              fatalError()
            }
        } else {
            // Fallback on earlier versions
        }


        // Handle authorization status
        switch status {
            case .restricted:
                self.loadCategoryFTUFlow()
                self.locateMeBtn.setImage(UIImage(named: "Locate me OFF"), for: .normal)
            case .denied:
                self.loadCategoryFTUFlow()
                self.locateMeBtn.setImage(UIImage(named: "Locate me OFF"), for: .normal)
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
                self.locateMeBtn.setImage(UIImage(named: "Locate me OFF"), for: .normal)
            case .authorizedAlways: fallthrough
            case .authorizedWhenInUse:
                self.loadCategoryFTUFlow()
                self.locateMeBtn.setImage(UIImage(named: "Locate me"), for: .normal)
                SCUserDefaultsHelper.setCurrentLocation(manager.location ?? CLLocation(latitude: 0.0, longitude: 0.0))
            @unknown default:
              fatalError()
        }
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Display the map using the default location.
        self.mapView?.isHidden = false
        locationManager.stopUpdatingLocation()
    }
}
