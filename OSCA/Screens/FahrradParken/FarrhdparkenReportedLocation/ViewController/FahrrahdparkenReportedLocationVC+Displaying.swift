/*
Created by Bhaskar N S on 19/05/23.
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

import Foundation
import GoogleMaps

extension FahrrahdparkenReportedLocationVC: FahrradparkenReportedLocationViewDisplay {
    fileprivate func setupViewBasedOnFlow() {
        switch presenter.getServiceFlow() {
        case .fahrradParken(let flow):
            switch flow {
            case .submitRequest:
                topContainer.isHidden = false
                buttonContainer.isHidden = false
            case .viewRequest:
                topContainer.isHidden = true
                buttonContainer.isHidden = true
            }
        case .defectReporter:
            break
        }
    }
    
    func updateNavigationTitle(navTitle: String?) {
        self.title = navTitle
        setupViewBasedOnFlow()
    }
    
    func showBtnActivityIndicator(_ show : Bool) {
        self.searchThisAreaButton.btnState = show ? .progress : .normal
    }
    
    func plotMarkersAtReported(locations: [FahrradparkenLocation]) {
        markers.removeAll()
        mapView?.clear()
        searchThisAreaButton.isHidden = true
        for (index, location) in locations.enumerated() {
            let markerImage = self.drawImageWithCategory(icon: statusIconFor(location: location),
                                                         image: UIImage(named: "icon_default_pin")!.maskWithColor(color: getMarkerSpotStatusColor(for: location))!)
            self.addMarker(latitude: location.lat,
                           longitude: location.long,
                           title: location.serviceName ?? "",
                           image: markerImage,
                           index: index)
            
        }
    }
    
    func selectedStatusIconFor(location: FahrradparkenLocation) -> UIImage {
        guard let extenedAttributes = location.extendedAttributes,
              let markASpot = extenedAttributes.markaspot,
              let status = markASpot.statusIcon else {
            return (UIImage(named: "bike-parking-default-selected")?.withRenderingMode(.alwaysOriginal))!
        }
        switch status {
        case "Done":
            return (UIImage(named: "bike-parking-done-selected")?.withRenderingMode(.alwaysOriginal))!
        case "Error":
            return (UIImage(named: "bike-parking-error-selected")?.withRenderingMode(.alwaysOriginal))!
        case "In Progress":
            return (UIImage(named: "bike-parking-in-progress-selected")?.withRenderingMode(.alwaysOriginal))!
        case "Queued":
            return (UIImage(named: "bike-parking-queued-selected")?.withRenderingMode(.alwaysOriginal))!
        default:
            return (UIImage(named: "bike-parking-done-default")?.withRenderingMode(.alwaysOriginal))!
            
        }
    }
    
    func statusIconFor(location: FahrradparkenLocation) -> UIImage {
        guard let extenedAttributes = location.extendedAttributes,
              let markASpot = extenedAttributes.markaspot,
              let status = markASpot.statusIcon else {
            return (UIImage(named: "bike-parking-default")?.withRenderingMode(.alwaysOriginal))!
        }
        switch status {
        case "Done":
            return (UIImage(named: "bike-parking-done")?.withRenderingMode(.alwaysOriginal))!
        case "Error":
            return (UIImage(named: "bike-parking-error")?.withRenderingMode(.alwaysOriginal))!
        case "In Progress":
            return (UIImage(named: "bike-parking-in-progress")?.withRenderingMode(.alwaysOriginal))!
        case "Queued":
            return (UIImage(named: "bike-parking-queued")?.withRenderingMode(.alwaysOriginal))!
        default:
            return (UIImage(named: "bike-parking-default")?.withRenderingMode(.alwaysOriginal))!
            
        }
    }
    
    func addMarker(latitude: Double?, longitude: Double?, title: String, image: UIImage, index : Int) {
        guard let latitude = latitude, let longitude = longitude else {
            return
        }
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude,
                                                 longitude: longitude)
        marker.userData = ["index": index]
        marker.accessibilityLabel = title
        marker.title?.accessibilityElementsHidden = true
        marker.icon?.accessibilityElementsHidden = true
        marker.accessibilityLabel = title
        marker.tracksViewChanges = false
        marker.icon = image
        marker.map = mapView
        self.markers.append(marker)
    }
    
    func present(viewController: UIViewController) {
        viewController.modalPresentationStyle = .overFullScreen
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        self.navigationController?.present(viewController, animated: true)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true)
        completionAfterDismiss?()
    }
    
    func drawImageWithCategory(icon: UIImage, image: UIImage, isSelected: Bool = false) -> UIImage {

        let imgView = UIImageView(image: image)
//        imgView.frame = CGRect(x: 0, y: 0, width: 30, height: 45)

        let picImgView = UIImageView(image: icon)
        if isSelected == false {
            picImgView.frame = CGRect(x: 0, y: 4, width: 24, height: 24)
        }
        imgView.addSubview(picImgView)

        picImgView.center.x = imgView.center.x
        picImgView.clipsToBounds = true
        imgView.setNeedsLayout()
        picImgView.setNeedsLayout()

        let newImage = imageWithView(view: imgView)
        return newImage
    }
    
    func imageWithView(view: UIView) -> UIImage {
        var image: UIImage?
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image ?? UIImage()
    }
    
    func clearAllMarkers() {
        markers.removeAll()
        mapView?.clear()
    }

    func getMarkerSpotStatusColor(for location: FahrradparkenLocation) -> UIColor {
        if let statusHex = location.extendedAttributes?.markaspot?.statusHex {
            return UIColor(hexString: statusHex)
        }
        return kColor_cityColor
    }
}
