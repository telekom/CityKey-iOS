//
//  SCBasicPOIGuideListMapFilterViewController+Delegate.swift
//  OSCA
//
//  Created by A106551118 on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
