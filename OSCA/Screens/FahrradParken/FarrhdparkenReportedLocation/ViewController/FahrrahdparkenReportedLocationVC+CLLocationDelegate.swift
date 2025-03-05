/*
Created by Bhaskar N S on 13/06/23.
Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
