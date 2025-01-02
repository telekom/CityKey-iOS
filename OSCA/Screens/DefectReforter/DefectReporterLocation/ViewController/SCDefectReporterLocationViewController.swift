//
//  SCDefectReporterLocationViewController.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 06/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import GoogleMaps

class SCDefectReporterLocationViewController: UIViewController {

    public var presenter: SCDefectReporterLocationPresenting!

    var locationManager: CLLocationManager!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var locationInfoLabel: UILabel!
    @IBOutlet weak var locateMeBtn: UIButton!
    @IBOutlet weak var savePositionBtn: SCCustomButton!
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var markerPinBtn: UIButton!
    @IBOutlet weak var locationInfoLabelViewHeight: NSLayoutConstraint!

    var zoomFactorMax : Float = 15.0
    var zoomFactorMin : Float = 10.0

    var mapView : GMSMapView?
    weak var delegate : SCMapViewDelegate?
    var completionAfterDismiss: (() -> Void)? = nil
    private var marker = GMSMarker()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the location manager.
        self.configureLocationManager()
        
        self.setupUI()
        
        self.setupAccessibilityIDs()
        self.setupAccessibility()

        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()

        handleDynamicTypeChange()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDynamicTypeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        navigationItem.title = LocalizationKeys.SCDefectReporterLocationViewController.dr002LocationSelectionToolbarLabel.localized()
        navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
        locationInfoLabel.adjustsFontForContentSizeCategory = true
        locationInfoLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 16, maxSize: 22)
        savePositionBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        savePositionBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
        
        if let locationInfoLabelFont = locationInfoLabel.font, let locationInfoLabelText = locationInfoLabel.text {
            let heightLocationInfoLabel = locationInfoLabelText.estimatedHeight(withConstrainedWidth: locationInfoLabel.frame.width, font: locationInfoLabelFont)
            self.locationInfoLabelViewHeight.constant = CGFloat(heightLocationInfoLabel)
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
        self.refreshNavigationBarStyle()
        // To avoid flickeing issue on google maps for dark mode
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                self.showActivityOverlay(on: mapViewContainer, hideActivityIndicator: true)
                SCUtilities.delay(withTime: 1.0) {
                    self.hideOverlay(on: self.mapViewContainer)
                }
            }
        }
        self.configureMap()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.mapView?.setupMapForDarkMode()
    }

    func configureLocationManager(){
            // Initialize the location manager.
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.delegate = self
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        self.locationInfoLabel.accessibilityIdentifier = "lbl_location_info"
        self.locateMeBtn.accessibilityIdentifier = "btn_locate_me"
        self.closeBtn.accessibilityIdentifier = "btn_close"

    }

    private func setupAccessibility(){
        self.navigationItem.backButtonTitle?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.locationInfoLabel.accessibilityLabel = self.locationInfoLabel.text
        self.locationInfoLabel.accessibilityTraits = .staticText
        self.locationInfoLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.locateMeBtn.accessibilityTraits = .button
        self.locateMeBtn.accessibilityLabel = LocalizationKeys.SCDefectReporterLocationViewController
            .dr002LocateMeButtonLabel.localized()
        self.locateMeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = LocalizationKeys.SCDefectReporterLocationViewController.poi002CloseButtonContentDescription.localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()

    }
    
    func configureMap(){
                
        // Create a map.
        // select cameraporsition and add marker
        let location = !SCUserDefaultsHelper.getDefectLocationStatus() ? SCUserDefaultsHelper.getCurrentLocation() : SCUserDefaultsHelper.getDefectLocation()
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let camera = GMSCameraPosition(latitude: 0.0, longitude: longitude, zoom: 0.0)

        if self.mapView == nil {
            mapView = GMSMapView(frame: mapViewContainer.bounds, camera: camera)
            self.mapView!.delegate = self
            self.mapView!.translatesAutoresizingMaskIntoConstraints = false
            self.mapView!.isMyLocationEnabled = true
            self.mapView!.isUserInteractionEnabled = true
            self.mapView?.accessibilityElementsHidden = false
            self.mapView?.settings.allowScrollGesturesDuringRotateOrZoom = true
            
            self.mapView?.setupMapForDarkMode()

            self.mapViewContainer.addSubview(mapView!)
            
            let ctLeading = NSLayoutConstraint(item: self.mapView!, attribute: .leading, relatedBy: .equal, toItem: self.mapViewContainer, attribute: .leading, multiplier: 1.0, constant: 0.0)
            let ctTrailing = NSLayoutConstraint(item: self.mapView!, attribute: .trailing, relatedBy: .equal, toItem: self.mapViewContainer, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            let ctTop = NSLayoutConstraint(item: self.mapView!, attribute: .top, relatedBy: .equal, toItem: self.mapViewContainer, attribute: .top, multiplier: 1.0, constant: 0.0)
            let ctBottom = NSLayoutConstraint(item: self.mapView!, attribute: .bottom, relatedBy: .equal, toItem: self.mapViewContainer, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            self.mapViewContainer.addConstraint(ctLeading)
            self.mapViewContainer.addConstraint(ctTrailing)
            self.mapViewContainer.addConstraint(ctBottom)
            self.mapViewContainer.addConstraint(ctTop)
            
//            self.addDefectLocationMarker(latitude: latitude, longitude: longitude)

        } else {
            self.mapView?.moveCamera(GMSCameraUpdate.setCamera(camera))
        }
    }
    
    func addDefectLocationMarker(latitude: CLLocationDegrees,
                                 longitude: CLLocationDegrees){
        self.mapView?.clear()
        
        marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.icon = GMSMarker.markerImage(with: kColor_cityColor)
        marker.title = title
        marker.accessibilityLabel = title
        marker.title?.accessibilityElementsHidden = true
        marker.icon?.accessibilityElementsHidden = true
        marker.map = mapView
    }

    @IBAction func locateMeBtnWasPressed(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
            self.showLocationFailedMessage(messageTitle:LocalizationKeys.SCDefectReporterLocationViewController.c001CitiesDialogGpsTitle.localized(),
                                           withMessage: LocalizationKeys.SCDefectReporterLocationViewController.c001CitiesDialogGpsMessage.localized())
        } else {
            if let location = locationManager.location {
                SCUserDefaultsHelper.setDefectLocation(location)
                self.reloadDefectLocationMap(location: location)
            }
        }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: UIButton) {
        self.presenter.closeButtonWasPressed()
    }
    
    @IBAction func savePositionBtnWasPressed(_ sender: UIButton) {
        SCUserDefaultsHelper.setDefectLocationStatus(status: true)
        self.updateDefectLocation()
        SCDataUIEvents.postNotification(for: .didChangeDefectLocation)

        self.dismiss(animated: true){
            self.completionAfterDismiss?()
            self.presenter.savePositionBtnWasPressed()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let strongSelf = self else {
                return
            }
            if UIDevice.current.orientation.isLandscape {
                // Adjust the zoom level for landscape orientation
                let newCamera = GMSCameraPosition.camera(withLatitude: strongSelf.mapView?.camera.target.latitude ?? 0.0,
                                                         longitude: strongSelf.mapView?.camera.target.longitude ?? 0.0,
                                                         zoom: strongSelf.zoomFactorMax)
                strongSelf.mapView?.camera = newCamera
            } else {
                // Adjust the zoom level for portrait orientation
                let newCamera = GMSCameraPosition.camera(withLatitude: strongSelf.mapView?.camera.target.latitude ?? 0.0,
                                                         longitude: strongSelf.mapView?.camera.target.longitude ?? 0.0,
                                                         zoom: strongSelf.zoomFactorMax)
                strongSelf.mapView?.camera = newCamera
            }
        }, completion: nil)
    }
}
