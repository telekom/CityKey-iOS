/*
Created by Michael on 18.10.18.
Copyright © 2018 Michael. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
