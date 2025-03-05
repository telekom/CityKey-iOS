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

import GoogleMaps

extension FahrrahdparkenReportedLocationVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let dict = marker.userData as? [String:Int],
           let markerIndex = dict["index"],
           let reportedLocation = presenter?.reportedLocations?[markerIndex] {
            let markerImage = self.drawImageWithCategory(icon: selectedStatusIconFor(location: reportedLocation).withRenderingMode(.alwaysOriginal).maskWithColor(color: getMarkerSpotStatusColor(for: reportedLocation))!,
                                                         image: UIImage(named: "icon_default_pin")!.maskWithColor(color: UIColor.white)!,
                                                         isSelected: true)
            marker.icon = markerImage
            selectedMarker = marker
            presenter.didTapMarker(with: reportedLocation)
            searchThisAreaButton.isHidden = true
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            if isZoomingInProgress {
                // Zoom in or zoom out stopped
                zoomEndTimer?.invalidate()
                zoomEndTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                    self?.isZoomingInProgress = false
                    // Perform any actions you want after zooming has stopped
                    self?.searchThisAreaButton.isHidden = false
                }
            }
        }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            isZoomingInProgress = true
            // Zoom in or zoom out started
            searchThisAreaButton.isHidden = true
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("mapview: idleAt position")
        print("** zoom level\(mapView.camera.zoom)")

        // Set the center coordinate
        let centerCoordinate = mapView.camera.target

        // Get the map size in points
        let mapSize = mapViewContainer.frame.size

        // Convert center coordinate to screen point
        let screenCenterPoint = mapView.projection.point(for: centerCoordinate)

        // Calculate the half-width and half-height of the screen
        let halfScreenWidth = mapSize.width / 2.0
        let halfScreenHeight = mapSize.height / 2.0

        // Calculate the screen points for the southwest and northeast corners of the bounding box
        let southwestScreenPoint = CGPoint(x: screenCenterPoint.x - halfScreenWidth, y: screenCenterPoint.y + halfScreenHeight)
        let northeastScreenPoint = CGPoint(x: screenCenterPoint.x + halfScreenWidth, y: screenCenterPoint.y - halfScreenHeight)

        // Convert screen points back to coordinates
        self.southwest = mapView.projection.coordinate(for: southwestScreenPoint)
        self.northeast = mapView.projection.coordinate(for: northeastScreenPoint)
    }
}
