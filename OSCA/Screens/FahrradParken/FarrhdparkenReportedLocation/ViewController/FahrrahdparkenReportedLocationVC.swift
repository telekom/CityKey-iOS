//
//  FahrrahdparkenReportedLocationVC.swift
//  OSCA
//
//  Created by Bhaskar N S on 19/05/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import GoogleMaps

class FahrrahdparkenReportedLocationVC: UIViewController {
    
    var presenter: FahrradparkenReportedLocationPresenting!
    var locationManager: CLLocationManager!
    @IBOutlet weak var markerPinBtn: UIButton!
    @IBOutlet weak var locateMeBtn: UIButton!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var savePositionBtn: SCCustomButton!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var locateMeBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationInfoLabel: UILabel!
    
    var searchThisAreaButton: SCCustomButton!
    var zoomFactorMax : Float = 15.0
    var zoomFactorMin : Float = 10.0
    var previousZoomLevel: Float = 0.0
    var isZoomingInProgress = false
    var zoomEndTimer: Timer?
    var selectedMarker: GMSMarker?

    var mapView : GMSMapView?
    weak var delegate : SCMapViewDelegate?
    var markers = [GMSMarker]()
    var northeast: CLLocationCoordinate2D?
    var southwest: CLLocationCoordinate2D?
    var completionAfterDismiss: (() -> Void)? = nil
    let markerDensity: [Int: Int] = [
        15: 300,    // Zoom level 15: 500 marker
        14: 400,    // Zoom level 14: 400 markers
        13: 500,    // Zoom level 13: 500 markers
        12: 600,   // Zoom level 12: 600 markers
        11: 700,
        10: 800,
        9: 900,
        8: 1000,
        7: 1100,
        6: 1200,
        5: 1300,
        4: 1400,
        3: 1500,
        2: 1600,
        1: 1700]


    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the location manager.
        self.configureLocationManager()
        self.setupUI()
        
        self.setupAccessibilityIDs()
        self.setupAccessibility()

        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        self.configureMap()
        handleDynamicTypeChange()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDynamicTypeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    func updateMarkerState() {
        if let marker = selectedMarker,
           let dict = marker.userData as? [String:Int],
           let selectedMarkerIndex = dict["index"],
           let locations = presenter.reportedLocations {
            let location = locations[selectedMarkerIndex]
            let markerImage = self.drawImageWithCategory(icon: statusIconFor(location: location),
                                                         image: UIImage(named: "icon_default_pin")!.maskWithColor(color: getMarkerSpotStatusColor(for: location))!)
            marker.icon = markerImage
            selectedMarker = nil
        }
    }
    
    func setupUI() {
        self.navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
        
        self.locateMeBtn.clipsToBounds = true
        self.locateMeBtn.layer.cornerRadius = self.locateMeBtn.frame.size.width/2
        
        self.markerPinBtn.setImage(GMSMarker.markerImage(with: kColor_cityColor), for: .normal)
        
        savePositionBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        savePositionBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
        self.savePositionBtn.customizeCityColorStyle()
        self.savePositionBtn.titleLabel?.adaptFontSize()
        self.savePositionBtn.setTitle(LocalizationKeys.SCDefectReporterLocationViewController.dr002SaveButtonLabel.localized(), for: .normal)
        self.locationInfoLabel.attributedText = LocalizationKeys.FahrrahdparkenReportedLocationVC.fa007LocationPageInfo.localized().applyHyphenation()
        setupUIBasedOnFlow()
    }
    
    private func setupUIBasedOnFlow() {
        let service = presenter.getServiceFlow()
        switch service {
        case .defectReporter:
            break
        case .fahrradParken(let flow):
            switch flow {
            case .submitRequest:
                closeBtn.isEnabled = true
                closeBtn.tintColor = UIColor(named: "CLR_NAVBAR_SOLID_ITEMS")
                locateMeBottomConstraint.constant = 90
            case .viewRequest:
                closeBtn.isEnabled = false
                closeBtn.tintColor = .clear
                markerPinBtn.isHidden = true
            }
        }
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        self.locateMeBtn.accessibilityIdentifier = "btn_locate_me"
        self.closeBtn.accessibilityIdentifier = "btn_close"
    }
    
    @objc private func handleDynamicTypeChange() {
//        // Dynamic font
        navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
        locationInfoLabel.adjustsFontForContentSizeCategory = true
        locationInfoLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 16, maxSize: 22)
        savePositionBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        savePositionBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
    }
    
    func configureLocationManager(){
        //Check for Location Services
            // Initialize the location manager.
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.delegate = self
    }
    
    private func setupAccessibility() {
        self.navigationItem.backButtonTitle?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
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
        let location = presenter.getLocationForMap()
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        let camera = GMSCameraPosition(latitude: 0.0, longitude: 0.0, zoom: zoomFactorMax)

        if self.mapView == nil {
            let map = GMSMapView(frame: mapViewContainer.bounds, camera: camera)
            mapView = map
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
            
            // Create the button
            searchThisAreaButton = SCCustomButton(type: .custom)
            searchThisAreaButton.setTitle(LocalizationKeys.FahrrahdparkenReportedLocationVC.fa004SearchThisAreaLabel.localized(),
                                          for: .normal)
            searchThisAreaButton.btnState = .normal
            searchThisAreaButton.titleLabel?.textAlignment = .center
            searchThisAreaButton.titleLabel?.numberOfLines = 0
            searchThisAreaButton.customizeBlueStyleSolidLight()
            searchThisAreaButton.translatesAutoresizingMaskIntoConstraints = false

            searchThisAreaButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            mapView?.addSubview(searchThisAreaButton)
            searchThisAreaButton.centerXAnchor.constraint(equalTo: mapViewContainer.centerXAnchor).isActive = true
            searchThisAreaButton.topAnchor.constraint(equalTo: mapViewContainer.topAnchor, constant: 60).isActive = true
            
            
            searchThisAreaButton.titleLabel?.adjustsFontForContentSizeCategory = true
            searchThisAreaButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 20)
            searchThisAreaButton.titleLabel?.numberOfLines = 0
            let btnHeight = searchThisAreaButton.titleLabel?.text?.estimatedHeight(withConstrainedWidth: searchThisAreaButton.frame.width,
                                                                                      font: (searchThisAreaButton.titleLabel?.font)!) ?? 30.0
            let searchThisBtnHeight = btnHeight <= GlobalConstants.kSearchThisAreaButtonHeight ? GlobalConstants.kSearchThisAreaButtonHeight : btnHeight
            
            searchThisAreaButton.widthAnchor.constraint(equalToConstant: 145).isActive = true
            searchThisAreaButton.heightAnchor.constraint(equalToConstant: searchThisBtnHeight + 5).isActive = true
            searchThisAreaButton.isHidden = true
        } else {
            self.mapView?.moveCamera(GMSCameraUpdate.setCamera(camera))
        }
        getBoudingBox()
        presenter.fetchReportedLocations(northEastCoordinate: northeast,
                                         southWestCoordinate: southwest,
                                         limit: markerDensity[Int(mapView?.camera.zoom ?? 0)] ?? 200)
    }
    
    private func getBoudingBox() {
        guard let mapView = mapView else { return }
        let visibleRegion = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        northeast = bounds.northEast
        southwest = bounds.southWest
    }
    
    @objc func buttonTapped() {
        presenter.fetchReportedLocations(northEastCoordinate: northeast,
                                         southWestCoordinate: southwest,
                                         limit: markerDensity[Int(mapView?.camera.zoom ?? 0)] ?? 200)
    }
    
    func reloadDefectLocationMap(location: CLLocation){
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            let camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: self.zoomFactorMax)
            self.mapView?.moveCamera(GMSCameraUpdate.setCamera(camera))
        })
    }
    
    @IBAction func searchThisAreaTapped(_ sender: Any) {
        presenter.fetchReportedLocations(northEastCoordinate: northeast, southWestCoordinate: southwest, limit: 200)
    }
    
    @IBAction func savePositionTapped(_ sender: Any) {
        SCUserDefaultsHelper.setDefectLocationStatus(status: true)
        self.updateDefectLocation()
        SCDataUIEvents.postNotification(for: .didChangeDefectLocation)
        self.dismiss(animated: true) {
            self.completionAfterDismiss?()
            self.presenter.savePositionBtnWasPressed()
        }
    }
    
    func updateDefectLocation(){
        let coordinate = mapView?.projection.coordinate(for: mapView!.center)
        print("latitude " + "\(coordinate!.latitude)" + " longitude " + "\(coordinate!.longitude)")
        var destinationLocation = CLLocation()
        destinationLocation = CLLocation(latitude: coordinate!.latitude,  longitude: coordinate!.longitude)
        SCUserDefaultsHelper.setDefectLocation(destinationLocation)
    }
    
    @IBAction func closeBtnWasPressed(_ sender: UIButton) {
        self.presenter.closeButtonWasPressed()
    }
    
    @IBAction func locateMeBtnWasPressed(_ sender: UIButton) {
        
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted { //|| CLLocationManager.authorizationStatus() == .notDetermined {
            self.showLocationFailedMessage(messageTitle:LocalizationKeys.SCDefectReporterLocationViewController.c001CitiesDialogGpsTitle.localized(), withMessage: LocalizationKeys.SCDefectReporterLocationViewController.c001CitiesDialogGpsMessage.localized())
        }else{
            if let location = locationManager.location {
                SCUserDefaultsHelper.setDefectLocation(location)
                self.reloadDefectLocationMap(location: location)
            }
        }
        
    }
    
    func showLocationFailedMessage(messageTitle: String, withMessage: String) -> Void  {
        let alertController = UIAlertController(title: messageTitle as String, message: withMessage as String, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LocalizationKeys.SCDefectReporterLocationViewController.c001CitiesDialogGpsBtnCancel.localized(), style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: LocalizationKeys.SCDefectReporterLocationViewController.c001CitiesDialogGpsBtnOk.localized(), style: .default) { (action:UIAlertAction!) in
            
            if let url = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
}
