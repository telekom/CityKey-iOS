/*
Created by A106551118 on 07/07/22.
Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, A106551118
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
