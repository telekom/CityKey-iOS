/*
Created by Harshada Deshmukh on 26/02/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import GoogleMaps

class SCBasicPOIGuideListMapFilterViewController: UIViewController {

    public var presenter: SCBasicPOIGuideListMapFilterPresenting!

    var locationManager: CLLocationManager!
    
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var listHiglightLbl: UILabel!
    @IBOutlet weak var mapHiglightLbl: UILabel!
    @IBOutlet weak var categoryViewContainer: UIView!
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var locateMeBtn: UIButton!
    @IBOutlet weak var poiOverlayView: UIView!
    @IBOutlet weak var poiOverlayInfoView: UIView!
    @IBOutlet weak var poiOverlayLbl: UILabel!
    @IBOutlet weak var poiOverlayCategoryLbl: UILabel!
    @IBOutlet weak var poiOverlaySubtitleLbl: UILabel!
    @IBOutlet weak var poiOverlayAddressLbl: UILabel!
    @IBOutlet weak var poiOverlayAddressLabel: UILabel!
    @IBOutlet weak var poiOverlayOpenHoursLbl: UILabel!
    @IBOutlet weak var poiOverlayOpenHoursTxtV: UITextView!
    @IBOutlet weak var poiOverlayCloseBtn: UIButton!
    @IBOutlet weak var poiOverlayCategoryIcon: UIImageView!
    @IBOutlet weak var poiOverlayArrowBtn: UIButton!
    @IBOutlet weak var poiOverlayCategoryStack: UIStackView!
    @IBOutlet weak var poiOverlayOpenHoursTxtVHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var getDirectionLabel: UILabel!
    @IBOutlet weak var getDirectionContainer: UIView!
    
    var mapView : GMSMapView?
    weak var delegate : SCMapViewDelegate?

    private let marker = GMSMarker()

    private var zoomFactorMax : Float = 15.0
    private var zoomFactorMin : Float = 14.0

    private var markers = [GMSMarker]()
    private var bounds = GMSCoordinateBounds()
    var isListSelected : Bool = false
    
    var poiItems: [POIInfo]?
    var selectedPOI: POIInfo?
    
//    var latitude: Double = 0.0
//    var longitude: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setDescriptionTexts()
        
        // Initialize the location manager.
        self.configureLocationManager()

        self.listTableView.dataSource = self
        self.listTableView.delegate = self
        
        self.listTableView.estimatedRowHeight = 44
        self.listTableView.rowHeight = UITableView.automaticDimension
                
        let categoryTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.catgegoryViewWasPressed))
        self.categoryViewContainer.addGestureRecognizer(categoryTapGesture)
        categoryTapGesture.cancelsTouchesInView = false
        
        let mapHiglightLblTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.mapBtnWasPressed(_:)))
        self.mapHiglightLbl.addGestureRecognizer(mapHiglightLblTapGesture)
        
        let listHiglightLblTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.listBtnWasPressed(_:)))
        self.listHiglightLbl.addGestureRecognizer(listHiglightLblTapGesture)
        
        let poiCategoryTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.poiOverlayViewWasPressed))
        self.poiOverlayCategoryStack.addGestureRecognizer(poiCategoryTapGesture)
        poiCategoryTapGesture.cancelsTouchesInView = false
        
        self.setupAccessibilityIDs()
        self.setupAccessibility()

        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()

        self.configureMap(latitude: self.presenter.getCityLocation().coordinate.latitude, 
						  longitude: self.presenter.getCityLocation().coordinate.longitude,
						  locationName: "",
						  locationAddress: "",
						  markerTintColor: kColor_cityColor)
        setupGetDirectionButton()
        
        if let currentCamera = mapView?.camera {
            let currentZoomLevel = currentCamera.zoom
            print("Current Zoom Level: \(currentZoomLevel)")
        } else {
            print("Unable to retrieve current zoom level.")
        }
        registerForNotification()
        handleDynamicTypeChange()
    }
    
    private func registerForNotification() {
        SCDataUIEvents.registerNotifications(for: self,
                                             on: UIContentSizeCategory.didChangeNotification,
                                             with: #selector(handleDynamicTypeChange))
    }

    @objc private func handleDynamicTypeChange() {
        listTableView.reloadData()
        poiOverlayLbl.adjustsFontForContentSizeCategory = true
        poiOverlayLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17.0, maxSize: 22.0)
        poiOverlayCategoryLbl.adjustsFontForContentSizeCategory = true
        poiOverlayCategoryLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        poiOverlaySubtitleLbl.adjustsFontForContentSizeCategory = true
        poiOverlaySubtitleLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        poiOverlayAddressLbl.adjustsFontForContentSizeCategory = true
        poiOverlayAddressLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        poiOverlayAddressLabel.adjustsFontForContentSizeCategory = true
        poiOverlayAddressLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        getDirectionLabel.adjustsFontForContentSizeCategory = true
        getDirectionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        poiOverlayOpenHoursLbl.adjustsFontForContentSizeCategory = true
        poiOverlayOpenHoursLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        poiOverlayOpenHoursTxtV.adjustsFontForContentSizeCategory = true
        poiOverlayOpenHoursTxtV.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        errorLabel.adjustsFontForContentSizeCategory = true
        errorLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 13.0, maxSize: 20.0)
        retryButton.titleLabel?.adjustsFontForContentSizeCategory = true
        retryButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 13.0, maxSize: 20.0)
        categoryLbl.adjustsFontForContentSizeCategory = true
        categoryLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17.0, maxSize: 22.0)
        listBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        listBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 24.0)
        mapBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        mapBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 24.0)
        setVisibilityOfListMapFilter()
    }

    private func setupGetDirectionButton() {
        getDirectionLabel.text = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.e006EventRoute.localized()
        getDirectionLabel.textColor = kColor_cityColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
        // To avoid flickeing issue on google maps for dark mode
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                self.showActivityOverlay(on: mapViewContainer, hideActivityIndicator: false)
                SCUtilities.delay(withTime: 0.5) {
                    self.hideOverlay(on: self.mapViewContainer)
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if let categoryIconImage = self.categoryIcon?.image{
                    self.categoryIcon?.image = categoryIconImage.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
                }
            }
        }
        
        self.mapView?.setupMapForDarkMode()
    }
    
    private func updateLocateMeBtn(){
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .notDetermined  {
            self.locateMeBtn.setImage(UIImage(named: "Locate me OFF"), for: .normal)
        }else{
            self.locateMeBtn.setImage(UIImage(named: "Locate me"), for: .normal)
        }
    }

    func configureLocationManager(){
        //Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {

            // Initialize the location manager.
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.distanceFilter = kCLDistanceFilterNone //50
            locationManager.startUpdatingLocation()
            locationManager.delegate = self
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func setDescriptionTexts() {
        listBtn.setTitle(LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001TabListLabel.localized(), for: .normal)
        mapBtn.setTitle(LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001TabMapLabel.localized(), for: .normal)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        self.listBtn.accessibilityIdentifier = "btn_list"
        self.mapBtn.accessibilityIdentifier = "btn_map"
        self.categoryLbl.accessibilityIdentifier = "lbl_category"
        self.locateMeBtn.accessibilityIdentifier = "btn_locate_me"
        self.poiOverlayLbl.accessibilityIdentifier = "lbl_poi_overlay"
        self.poiOverlayCategoryLbl.accessibilityIdentifier = "lbl_poi_overlay_category"
        self.poiOverlaySubtitleLbl.accessibilityIdentifier = "lbl_poi_overlay_subtitle"
        self.poiOverlayAddressLbl.accessibilityIdentifier = "lbl_poi_overlay_address_heading"
        self.poiOverlayAddressLabel.accessibilityIdentifier = "lbl_poi_overlay_address"
        self.poiOverlayOpenHoursLbl.accessibilityIdentifier = "lbl_poi_overlay_open_hours_heading"
        self.poiOverlayOpenHoursTxtV.accessibilityIdentifier = "lbl_poi_overlay_open_hours"
        self.poiOverlayCloseBtn.accessibilityIdentifier = "btn_poi_overlay_close"
        self.poiOverlayCategoryIcon.accessibilityIdentifier = "img_poi_overlay_categeory"
        self.poiOverlayArrowBtn.accessibilityIdentifier = "btn_poi_overlay_next"
        self.retryButton.accessibilityIdentifier = "btn_retry_error"

    }

    private func setupAccessibility(){
        self.navigationItem.backButtonTitle?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.retryButton.accessibilityTraits = .button
        self.retryButton.accessibilityLabel = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001RetryButtonDecription.localized()
        self.retryButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.listBtn.accessibilityTraits = .button
        self.listBtn.accessibilityLabel = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001TabListLabel.localized()
        self.listBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.mapBtn.accessibilityTraits = .button
        self.mapBtn.accessibilityLabel = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001TabMapLabel.localized()
        self.mapBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.categoryLbl.accessibilityLabel = self.categoryLbl.text
        self.categoryLbl.accessibilityTraits = .staticText
        self.categoryLbl.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.categoryIcon.accessibilityElementsHidden = true
        self.locateMeBtn.accessibilityTraits = .button
        self.locateMeBtn.accessibilityLabel = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001TabMapLocateMeButtonDecription.localized()
        self.locateMeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.poiOverlayLbl.accessibilityLabel = self.poiOverlayLbl.text
        self.poiOverlayLbl.accessibilityTraits = .header
        self.poiOverlayLbl.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.poiOverlayCloseBtn.accessibilityTraits = .button
        self.poiOverlayCloseBtn.accessibilityLabel = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi002CloseButtonContentDescription.localized()
        self.poiOverlayCloseBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.poiOverlayView.accessibilityTraits = .staticText
        let category = (self.poiOverlayCategoryLbl.text ?? "") + ", "
        let subtitle = !self.poiOverlaySubtitleLbl.text!.isSpaceOrEmpty() ? (self.poiOverlaySubtitleLbl.text ?? "") + ", " : ""
        let address = !self.poiOverlayAddressLabel.text!.isSpaceOrEmpty() ? (self.poiOverlayAddressLbl.text ?? "") + ", " + (self.poiOverlayAddressLabel.text ?? "") + ", " : ""
        let openHours = !self.poiOverlayOpenHoursTxtV.text!.isSpaceOrEmpty() ? (self.poiOverlayOpenHoursLbl.text ?? "") + ", " + (self.poiOverlayOpenHoursTxtV.text ?? "") + ", " : ""
        self.poiOverlayView.accessibilityLabel = category + subtitle + address + openHours
        self.poiOverlayView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.poiOverlayView.isAccessibilityElement = true
                
        self.poiOverlayCategoryLbl.accessibilityElementsHidden = true
        self.poiOverlaySubtitleLbl.accessibilityElementsHidden = true
        self.poiOverlayAddressLbl.accessibilityElementsHidden = true
        self.poiOverlayAddressLabel.accessibilityElementsHidden = true
        self.poiOverlayOpenHoursLbl.accessibilityElementsHidden = true
        self.poiOverlayOpenHoursTxtV.accessibilityElementsHidden = true
        self.poiOverlayCategoryIcon.accessibilityElementsHidden = true
        self.poiOverlayArrowBtn.accessibilityElementsHidden = true
        categoryViewContainer.accessibilityTraits = .button
        categoryViewContainer.accessibilityHint = "accessibility_change_category".localized()
        categoryViewContainer.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    func configureMap(latitude: Double,
                  longitude: Double,
                  locationName: String,
                  locationAddress: String,
                  markerTintColor: UIColor){
                
        // Create a map.
        // select cameraporsition and add marker
        let camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: zoomFactorMin)
        self.marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.marker.icon = GMSMarker.markerImage(with: markerTintColor)
        
        self.marker.title = locationName
        if self.mapView == nil {
            let map = GMSMapView(frame: mapViewContainer.bounds, camera: camera)
            mapView = map

            self.mapView!.translatesAutoresizingMaskIntoConstraints = false
            self.mapView!.isMyLocationEnabled = true
            self.mapView!.isUserInteractionEnabled = true
            self.marker.map = mapView
            self.mapView?.accessibilityElementsHidden = false
            self.mapViewContainer.addSubview(mapView!)
            self.mapView!.delegate = self
            
            self.mapView?.setupMapForDarkMode()

            let ctLeading = NSLayoutConstraint(item: self.mapView!, attribute: .leading, relatedBy: .equal, toItem: self.mapViewContainer, attribute: .leading, multiplier: 1.0, constant: 0.0)
            let ctTrailing = NSLayoutConstraint(item: self.mapView!, attribute: .trailing, relatedBy: .equal, toItem: self.mapViewContainer, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            let ctTop = NSLayoutConstraint(item: self.mapView!, attribute: .top, relatedBy: .equal, toItem: self.mapViewContainer, attribute: .top, multiplier: 1.0, constant: 0.0)
            let ctBottom = NSLayoutConstraint(item: self.mapView!, attribute: .bottom, relatedBy: .equal, toItem: self.mapViewContainer, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            self.mapViewContainer.addConstraint(ctLeading)
            self.mapViewContainer.addConstraint(ctTrailing)
            self.mapViewContainer.addConstraint(ctBottom)
            self.mapViewContainer.addConstraint(ctTop)

        } else {
//            self.mapView?.animate(to: camera)
            self.showPOIItems(self.poiItems ?? [])
        }
    }
    
    func showPOIItems(_ poiItems: [POIInfo]){
        
        self.markers.removeAll()
        self.mapView?.clear()

        self.loadPOIMarkers(poiItems: poiItems)
                
        var camera = GMSCameraPosition.camera(withLatitude: Double(self.presenter.getCityLocation().coordinate.latitude),
                                              longitude: Double(self.presenter.getCityLocation().coordinate.longitude),
                                              zoom: zoomFactorMin)

        if poiItems.count < 50 {
            //fit map to markers
            let gmsMarkers = self.markers
            var bounds = GMSCoordinateBounds()
            for marker in gmsMarkers {
                bounds = bounds.includingCoordinate(marker.position)
            }
            print("paddingBasedOnOrientation: \(paddingBasedOnOrientation())")
            DispatchQueue.main.async {
                let update = GMSCameraUpdate.fit(bounds,
                                                 withPadding: self.paddingBasedOnOrientation())
                self.mapView?.animate(with: update)
            }
        }
        else if poiItems.count > 150 {
            camera = GMSCameraPosition.camera(withLatitude: Double(self.presenter.getCityLocation().coordinate.latitude), longitude: Double(self.presenter.getCityLocation().coordinate.longitude), zoom: zoomFactorMax)
            self.mapView?.animate(to: camera)
        }else{
            self.mapView?.animate(to: camera)
        }
    }
    
    private func paddingBasedOnOrientation() -> CGFloat {
        if let poiItems = poiItems, poiItems.count > 20 {
            return UIDevice.current.orientation.isLandscape ? 10.0 : 50.0
        } else {
            return UIDevice.current.orientation.isLandscape ? 5.0 : 100.0
        }
    }
    
    func loadPOIMarkers(poiItems: [POIInfo]){
        self.poiItems = poiItems

        let markerImage = self.drawImageWithCategory(icon: SCUserDefaultsHelper.setupCategoryIcon(SCUserDefaultsHelper.getPOICategoryGroupIcon() ?? "").maskWithColor(color: UIColor(named: "CLR_BUTTON_WHITE_BCKGRND")!)!, image: UIImage(named: "icon_default_pin")!.maskWithColor(color: kColor_cityColor)!)

        for (index,poi) in poiItems.enumerated() {
            self.addMarker(latitude: Double(poi.latitude), longitude: Double(poi.longitude), title: poi.title, markerColor: kColor_cityColor, image: markerImage, index: index)
        }
    }
    
    func addMarker(latitude: Double, longitude: Double, title: String, markerColor: UIColor, image: UIImage, index : Int){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.userData = ["index": index]
        marker.icon = image
        marker.title = title
        marker.accessibilityLabel = title
        marker.title?.accessibilityElementsHidden = true
        marker.icon?.accessibilityElementsHidden = true
        marker.accessibilityLabel = title
        marker.tracksViewChanges = false
        marker.tracksInfoWindowChanges = false
        marker.map = mapView
        self.markers.append(marker)
    }
    
    @IBAction func mapBtnWasPressed(_ sender: UIButton) {
        self.isListSelected = false
        self.hidePOIOverlay()
        self.setVisibilityOfListMapFilter()
        self.loadPois(self.poiItems ?? [])
    }
    
    @IBAction func listBtnWasPressed(_ sender: UIButton) {
        self.isListSelected = true
        self.hidePOIOverlay()
        self.setVisibilityOfListMapFilter()
        self.loadPois(self.poiItems ?? [])
    }
    
    func setVisibilityOfListMapFilter(){
        self.updateLocateMeBtn()
        self.mapViewContainer.isHidden = !self.isListSelected ? false : true
        self.listTableView.isHidden = !self.isListSelected ? true : false
        self.mapHiglightLbl.backgroundColor = !self.isListSelected ? kColor_cityColor : UIColor(named: "CLR_CARD_BCKGRND")
        self.listHiglightLbl.backgroundColor = !self.isListSelected ? UIColor(named: "CLR_CARD_BCKGRND") : kColor_cityColor
        self.listBtn.titleLabel?.font = !self.isListSelected ? UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 24.0) : UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: 24.0)
        self.mapBtn.titleLabel?.font = !self.isListSelected ? UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: 24.0) :  UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 24.0)
    }
    
    @IBAction func locateMeBtnWasPressed(_ sender: UIButton) {
        
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted { //|| CLLocationManager.authorizationStatus() == .notDetermined {
            self.showLocationFailedMessage(messageTitle:LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.c001CitiesDialogGpsTitle.localized(), withMessage: LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.c001CitiesDialogGpsMessage.localized())
        }else{
            let camera = GMSCameraPosition.camera(withLatitude: self.mapView?.myLocation?.coordinate.latitude ?? 0.0, longitude: self.mapView?.myLocation?.coordinate.longitude ?? 0.0, zoom: zoomFactorMax)
            self.mapView?.animate(to: camera)
        }
        
    }
    
    @objc func catgegoryViewWasPressed() {
        self.hidePOIOverlay()
        self.presenter.categoryWasPressed()
    }
    
    @objc func poiOverlayViewWasPressed() {
        self.hidePOIOverlay()
        self.presenter.didSelectListItem(item: self.selectedPOI!)
    }

    func setupPOIOverlayView(){
        self.poiOverlayLbl.text = self.selectedPOI?.categoryName
        self.poiOverlayCategoryLbl.text = self.selectedPOI?.title
        self.poiOverlaySubtitleLbl.text = self.selectedPOI?.subtitle
        self.poiOverlayAddressLbl.text = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001AddressLabel.localized()
        self.poiOverlayAddressLabel.attributedText = self.selectedPOI?.address.applyHyphenation()
        
        self.poiOverlayOpenHoursLbl.text = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001OpeningHoursLabel.localized()
        let attrStringOH =  self.selectedPOI?.openHours.htmlAttributedString
        let htmlAttributedStringOH = NSMutableAttributedString(attributedString: attrStringOH!)
        htmlAttributedStringOH.replaceFont(with: self.poiOverlayOpenHoursTxtV.font!, color: self.poiOverlayOpenHoursTxtV.textColor!)
        self.poiOverlayOpenHoursTxtV.attributedText = htmlAttributedStringOH
        self.poiOverlayOpenHoursTxtV.linkTextAttributes = [.foregroundColor: kColor_cityColor]
        
        self.poiOverlayCategoryIcon.image = SCUserDefaultsHelper.setupCategoryIcon(SCUserDefaultsHelper.getPOICategoryGroupIcon() ?? "").maskWithColor(color: kColor_cityColor)
        self.poiOverlayAddressLbl.isHidden = !self.poiOverlayAddressLabel.text!.isSpaceOrEmpty() ? false : true
        self.poiOverlayOpenHoursLbl.isHidden = !self.poiOverlayOpenHoursTxtV.text!.isSpaceOrEmpty() ? false : true
        self.poiOverlayOpenHoursTxtV.textContainerInset = UIEdgeInsets.zero
        self.poiOverlayOpenHoursTxtV.textContainer.lineFragmentPadding = 0
        
        let heightOpenHrsTitle = self.poiOverlayOpenHoursTxtV.calculateViewHeightWithCurrentWidth()
        poiOverlayOpenHoursTxtVHeightConstraint.constant = !(self.poiOverlayOpenHoursTxtV.text.isSpaceOrEmpty()) ? CGFloat(heightOpenHrsTitle) : 0
        getDirectionContainer.isHidden = selectedPOI?.address.isSpaceOrEmpty() ?? true
        poiOverlayAddressLabel.isHidden = selectedPOI?.address.isSpaceOrEmpty() ?? true
    }
    
    @IBAction func retryBtnWasPressed(_ sender: Any) {
        self.presenter.didPressGeneralErrorRetryBtn()
    }
    
    @IBAction func poiOverlayCloseBtnWasPressed(_ sender: UIButton) {
        self.hidePOIOverlay()
    }
    
    @IBAction func poiOverlayArrowBtnWasPressed(_ sender: UIButton) {
        self.poiOverlayViewWasPressed()
    }

    @IBAction func getDirectionTapped(_ sender: Any) {
        guard let latitude = selectedPOI?.latitude,
              let longitude = selectedPOI?.longitude else {
            return
        }
        openMaps(latitude: Double(latitude),
                 longitude: Double(longitude),
                 title: selectedPOI?.address)
    }

    func openMaps(latitude: Double, longitude: Double, title: String?) {
        let application = UIApplication.shared
        let coordinate = "\(latitude),\(longitude)"
        let encodedTitle = title?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let handlers = [
            (LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.e006EventAppleMaps.localized(), "http://maps.apple.com/?q=\(encodedTitle)&ll=\(coordinate)"),
            (LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.e006EventGoogleMaps.localized(), "comgooglemaps://?q=\(coordinate)")
        ]
            .compactMap { (name, address) in URL(string: address).map { (name, $0) } }
            .filter { (_, url) in application.canOpenURL(url) }
        
        guard !handlers.isEmpty else {
            showUIAlert(with: LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.e006EventNoMapFoundText.localized())
            return
        }
        
        if handlers.count == 1, let url = handlers.first?.1 {
            application.open(url, options: [:])
        } else {
            let alert = UIAlertController(title: LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.e006EventRoutingOptions.localized(), message: LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.e006EventRoutingOptionsMsgText.localized(), preferredStyle: .actionSheet)
            handlers.forEach { (name, url) in
                alert.addAction(UIAlertAction(title: name, style: .default) { _ in
                    application.open(url, options: [:])
                })
            }
            alert.addAction(UIAlertAction(title: LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.e006EventBtnCancel.localized(),
                                          style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
        }, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            if let poiItems = strongSelf.poiItems {
                strongSelf.showPOIItems(poiItems)
            }
        })
    }
}
