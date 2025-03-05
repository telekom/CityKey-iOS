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
import GoogleMaps

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SCBasicPOIGuideListMapFilterViewController : UITableViewDelegate, UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.poiItems?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < self.poiItems?.count ?? 0 {
            let cell: SCBasicPOIGuideListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SCBasicPOIGuideListTableViewCell", for: indexPath) as! SCBasicPOIGuideListTableViewCell
            let poiListItem = self.poiItems?[indexPath.row]
                    
            cell.setup(poi: poiListItem!)
            cell.openHoursTxtV.delegate = self
            
            if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted || !(CLLocationManager.locationServicesEnabled()) {
                cell.distanceLabel.isHidden = true
            } else {
                cell.distanceLabel.isHidden = false
            }
            
            cell.setupAccessibilty(indexPath.row, count: self.poiItems?.count ?? 0)
            return cell
        } else {
            return UITableViewCell()
        }
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.presenter.didSelectListItem(item: (self.poiItems?[indexPath.row])! as POIInfo)
    }
}

// MARK: - GMSMapViewDelegate

extension SCBasicPOIGuideListMapFilterViewController: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        self.mapView?.selectedMarker  = marker
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let dict = marker.userData as? [String:Int] {

            let pois = self.poiItems?[dict["index"]!]
            self.selectedPOI = pois
            if self.selectedPOI != nil{
                self.showPOIOverlay()
            }
        }
        return false
    }

}
