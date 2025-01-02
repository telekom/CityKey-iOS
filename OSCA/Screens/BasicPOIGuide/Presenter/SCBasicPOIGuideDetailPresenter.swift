//
//  SCBasicPOIGuideDetailPresenter.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 23/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import MapKit
import TTGSnackbar

class SCBasicPOIGuideDetailPresenter {
    
    weak private var display: SCBasicPOIGuideDetailDisplaying?
    
    private let injector: SCBasicPOIGuideDetailInjecting & SCToolsInjecting & SCAdjustTrackingInjection
    private let poi: POIInfo
    private let cityID : Int
    
    init(cityID: Int, poi: POIInfo, injector: SCBasicPOIGuideDetailInjecting & SCToolsInjecting & SCAdjustTrackingInjection) {
        self.poi = poi
        self.injector = injector
        self.cityID = cityID
    }
    
    
    private func setupUI() {
        self.display?.setupUI(navTitle: self.poi.categoryName,
                              title: self.poi.title,
                              description: self.poi.description,
                              address: self.poi.address,
                              categoryName: self.poi.categoryName,
                              cityId: self.poi.cityId,
                              distance: self.poi.distance,
                              icon: self.poi.icon,
                              latitude: Double(self.poi.latitude),
                              longitude: Double(self.poi.longitude),
                              openHours: self.poi.openHours,
                              id: self.poi.id,
                              subtitle: self.poi.subtitle,
                              url: self.poi.url)
    }

}

extension SCBasicPOIGuideDetailPresenter: SCPresenting {
    func viewDidLoad() {
        self.setupUI()
    }
}

extension SCBasicPOIGuideDetailPresenter: SCMapViewDelegate {
    func mapWasTapped(latitude: Double, longitude: Double, zoomFactor: Float, address: String) {
        
    }
    
    func directionsBtnWasPressed(latitude : Double, longitude : Double, address: String){
        self.directionsButtonWasPressed(latitude : latitude, longitude : longitude, address: address)
    }
}

extension SCBasicPOIGuideDetailPresenter : SCBasicPOIGuideDetailPresenting {

    func setDisplay(_ display: SCBasicPOIGuideDetailDisplaying) {
        self.display = display
    }
    
    func mapViewWasPressed(latitude: Double, longitude: Double, zoomFactor: Float, address: String){
        let mapNavigationController = self.injector.getBasicPOIGuideDetailMapController(latitude: latitude, longitude: longitude, zoomFactor: zoomFactor, address: address, locationName: self.poi.title, tintColor: kColor_cityColor) as! UINavigationController
        let mapController = mapNavigationController.viewControllers.first as! SCMapViewController
        mapController.delegate = self
        mapController.title = self.poi.categoryName
        mapController.isFromPoiDetails = true
        self.display?.present(viewController: mapNavigationController)
    }

    func directionsButtonWasPressed(latitude : Double, longitude : Double, address: String) {
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = address
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    func reloadDetailPageContent() {
        self.setupUI()
    }
    
    func getShareBarButton() -> UIBarButtonItem? {
        let shareButton = UIBarButtonItem(image: UIImage(named: "icon_share"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(sharePOI))
        shareButton.accessibilityTraits = .button
        shareButton.accessibilityLabel = LocalizationKeys.SCBasicPOIGuideDetailPresenter.accessibilityBtnShareContent.localized()
        shareButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        return shareButton
    }

    @objc func sharePOI() {
        
        let title = !poi.title.isSpaceOrEmpty() ? poi.title + "\n" : ""
        let address = !poi.address.isSpaceOrEmpty() ? poi.address + "\n" : ""
        let subtitle = !poi.subtitle.isSpaceOrEmpty() ? poi.subtitle + "\n" : ""
        let description = !poi.description.isSpaceOrEmpty() ? poi.description + "\n" : ""
        let openHours = !poi.openHours.isSpaceOrEmpty() ? poi.openHours + "\n" : ""
        let url = !poi.url.isSpaceOrEmpty() ? poi.url + "\n" : ""
        let shareText = title + address + subtitle + description + openHours + url
       
        let objectToShare = "\(shareText)\n\n\(LocalizationKeys.SCBasicPOIGuideDetailPresenter.shareStoreHeader.localized())\n"
        SCShareContent.share(objects: [objectToShare], emailTitle: poi.title, sourceRect: nil)

    }
}
