//
//  FahrrahdparkenReportedLocationVC+CLLocationDelegate.swift
//  OSCA
//
//  Created by Bhaskar N S on 13/06/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import CoreLocation
import UIKit
import GoogleMaps

// MARK: - CLLocationManagerDelegate
// Delegates to handle events for the location manager.
extension FahrrahdparkenReportedLocationVC: CLLocationManagerDelegate {

    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = !SCUserDefaultsHelper.getDefectLocationStatus() ? locations.last! : SCUserDefaultsHelper.getDefectLocation()
        print("Location: \(location)")
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            self.mapView?.camera = GMSCameraPosition(target: position, zoom: self.zoomFactorMax)
        }


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
                print("Location accuracy is precise.")
            case .reducedAccuracy:
                print("Location accuracy is not precise.")
            @unknown default:
              fatalError()
            }
        } else {
            // Fallback on earlier versions
        }


        // Handle authorization status
        switch status {
            case .restricted:
                print("Location access was restricted.")
                self.updateLocateMeBtn()
                
            case .denied:
                print("User denied access to location.")
                self.updateLocateMeBtn()
                
            case .notDetermined:
                print("Location status not determined.")
                self.updateLocateMeBtn()
                self.locationManager.requestWhenInUseAuthorization()
                
            case .authorizedAlways:
                manager.startUpdatingLocation()
                self.updateLocateMeBtn()
                self.loadCurrentLocation()
            case .authorizedWhenInUse:
                print("Location status is OK.")
                manager.startUpdatingLocation()
                self.updateLocateMeBtn()
                self.loadCurrentLocation()
            @unknown default:
              fatalError()
        }
        
        
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Display the map using the default location.
        self.mapView?.isHidden = false
        locationManager.stopUpdatingLocation()
        print("Location Error: \(error)")
    }
    
    private func updateLocateMeBtn(){
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .notDetermined  {
            self.locateMeBtn.setImage(UIImage(named: "Locate me OFF"), for: .normal)

        }else{
            self.locateMeBtn.setImage(UIImage(named: "Locate me"), for: .normal)
        }
    }
    
    private func loadCurrentLocation() {
        if !SCUserDefaultsHelper.getDefectLocationStatus(),
           let location = self.locationManager.location {
            //load user current location
            SCUserDefaultsHelper.setCurrentLocation(location)
            self.reloadDefectLocationMap(location: location)
        } else {
            //load defect location
            self.reloadDefectLocationMap(location: SCUserDefaultsHelper.getDefectLocation())
        }
    }
}
