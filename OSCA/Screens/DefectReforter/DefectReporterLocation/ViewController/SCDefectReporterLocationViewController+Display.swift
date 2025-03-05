/*
Created by Bhaskar N S on 21/07/22.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
