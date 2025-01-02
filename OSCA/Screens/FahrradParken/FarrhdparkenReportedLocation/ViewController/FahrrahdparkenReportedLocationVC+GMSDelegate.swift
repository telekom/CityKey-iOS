//
//  FahrrahdparkenReportedLocationVC+GMSDelegate.swift
//  OSCA
//
//  Created by Bhaskar N S on 13/06/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
