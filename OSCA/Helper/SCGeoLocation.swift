//
//  SCGeoLocation.swift
//  SmartCity
//
//  Created by Michael on 18.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import CoreLocation

protocol SCGeoLocationDelegate: AnyObject {
    func locationSearchDidFinish(with latitude: Double, longitute: Double)
    func locationSearchDidFail()
    func locationSearchWasDenied()
}

class SCGeoLocation: NSObject, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    weak var delegate : SCGeoLocationDelegate?

    func searchLocation() -> Bool{
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers

        var success = false
        if CLLocationManager.locationServicesEnabled()
        {
            success = true
            switch(CLLocationManager.authorizationStatus())
            {
            case .authorizedAlways, .authorizedWhenInUse:
                debugPrint("EAuthorize.")
                locationManager.requestLocation()
                break
                
            case .notDetermined:
                debugPrint("ENot determined.")
                success = true
                break
                
            case .restricted:
                debugPrint("ERestricted.")
                success = false
                break
                
            case .denied:
                success = false
                debugPrint("EDenied.")
                
            @unknown default:
                success = false
                debugPrint("EUnknown status.")
            }
        } else {
            
        }
        return success
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let location = locations.first {
            self.delegate?.locationSearchDidFinish(with: location.coordinate.latitude, longitute: location.coordinate.longitude)
        } else {
            self.delegate?.locationSearchDidFail()
        }
        
    }
        
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.delegate?.locationSearchDidFail()
    }
    
    // Deprecated with iOS14
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status:CLAuthorizationStatus){
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
            _ = self.searchLocation()
        } else {
            if (status == .denied) {
                self.delegate?.locationSearchWasDenied()
            }
        }
    }
    
    // New with iOS14
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {

            let status = manager.authorizationStatus
            
            let accuracyAuthorization = manager.accuracyAuthorization
            switch accuracyAuthorization {
            case .fullAccuracy:
                break
            case .reducedAccuracy:
                break
            default:
                break
            }
            
            if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
                _ = self.searchLocation()
            } else {
                if (status == .denied) {
                    self.delegate?.locationSearchWasDenied()
                }
            }
        }
    }
}
