//
//  SCDefectReporterLocationViewController+Display.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import GoogleMaps
import CoreLocation

// MARK: - SCDefectReporterLocationViewController
extension SCDefectReporterLocationViewController: SCDefectReporterLocationViewDisplay {
    
    func setupUI() {
        
        self.navigationItem.title = LocalizationKeys.SCDefectReporterLocationViewController.dr002LocationSelectionToolbarLabel.localized()
        self.navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()

        self.locateMeBtn.clipsToBounds = true
        self.locateMeBtn.layer.cornerRadius = self.locateMeBtn.frame.size.width/2
        
        self.locationInfoLabel.adaptFontSize()
        self.locationInfoLabel.attributedText = LocalizationKeys.SCDefectReporterLocationViewController.dr003LocationPageInfo1.localized().applyHyphenation()
        
        self.savePositionBtn.customizeCityColorStyle()
        self.savePositionBtn.titleLabel?.adaptFontSize()
        self.savePositionBtn.setTitle(LocalizationKeys.SCDefectReporterLocationViewController.dr002SaveButtonLabel.localized(), for: .normal)

        self.markerPinBtn.setImage(GMSMarker.markerImage(with: kColor_cityColor), for: .normal)

    }
    
    func reloadDefectLocationMap(location: CLLocation){
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            let camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: self.zoomFactorMax)
            self.mapView?.moveCamera(GMSCameraUpdate.setCamera(camera))
        })
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true)
        completionAfterDismiss?()
    }

    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showLocationFailedMessage(messageTitle: String, withMessage: String) -> Void  {
        let alertController = UIAlertController(title: messageTitle as String, message: withMessage as String, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LocalizationKeys.SCDefectReporterLocationViewController.c001CitiesDialogGpsBtnCancel.localized(), style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: LocalizationKeys.SCDefectReporterLocationViewController.c001CitiesDialogGpsBtnOk.localized(), style: .default) { (action:UIAlertAction!) in
            
            if let url = URL(string:UIApplication.openSettingsURLString) {
                
                // this would be the path to the privacy settings
                // but it seems like we cant distinguish
                // "app permission disabled" from "location services disabled"
                // let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
}
