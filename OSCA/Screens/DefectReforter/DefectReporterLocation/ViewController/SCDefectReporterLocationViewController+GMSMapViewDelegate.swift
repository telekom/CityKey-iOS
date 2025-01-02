//
//  SCDefectReporterLocationViewController+GMSMapViewDelegate.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import GoogleMaps

// MARK: - GMSMapViewDelegate

extension SCDefectReporterLocationViewController: GMSMapViewDelegate {
        
    func updateDefectLocation(){
        let coordinate = mapView?.projection.coordinate(for: mapView!.center)
        print("latitude " + "\(coordinate!.latitude)" + " longitude " + "\(coordinate!.longitude)")
        var destinationLocation = CLLocation()
        destinationLocation = CLLocation(latitude: coordinate!.latitude,  longitude: coordinate!.longitude)
        SCUserDefaultsHelper.setDefectLocation(destinationLocation)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
//        self.updateDefectLocation()
    }
}
