//
//  SCEventDetailMapViewController.swift
//  SmartCity
//
//  Created by Michael on 23.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit

protocol SCMapViewDelegate: AnyObject {
    func mapWasTapped(latitude : Double, longitude : Double, zoomFactor : Float, address: String)
    func directionsBtnWasPressed(latitude : Double, longitude : Double, address: String)
}

class SCMapViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var locationlbl: UILabel!
    @IBOutlet weak var directionsBtn: UIButton!
    @IBOutlet weak var routeBtn: UIButton!

    @IBOutlet weak var iconImageView: UIImageView!
    
    private var mapView : GMSMapView?
    weak var delegate : SCMapViewDelegate?

    private let marker = GMSMarker()
    private let zoomFactor : Float = 17.0
    
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
    private var locationAddress: String = ""
    private var locationName: String = ""
    private var tintColor: UIColor = .clear
    private var mapInteractionEnabled: Bool = false
    private var readyToDisplay = false
    private var setupFinished = false
    private var showDirectionsBtn = false
    var isFromPoiDetails = false
    var locationLblHeight : CGFloat = 0
    @IBOutlet weak var locationViewContainer: UIView!
    @IBOutlet weak var routeBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationViewContainerHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshNavigationBarStyle()
        
        let mapTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.mapViewWasPressed))
        mapViewContainer.addGestureRecognizer(mapTapGesture)
        
        self.locationlbl.adaptFontSize()
        self.directionsBtn.titleLabel?.adaptFontSize()
        self.routeBtn.titleLabel?.adaptFontSize()

        self.directionsBtn.layer.shadowRadius = 3
        self.directionsBtn.layer.shadowOpacity = 0.4
        self.directionsBtn.layer.shadowOffset = CGSize(width: 0, height: 3)

        self.setupAccessibilityIDs()
        self.readyToDisplay = true
        
        self.iconImageView.image =  self.iconImageView.image?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        if setupFinished {
            self.displayMap(latitude: self.latitude, longitude: self.longitude, locationName: self.locationName, locationAddress: self.locationAddress, markerTintColor: self.tintColor)
        }
        handleDynamicTypeChange()

        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        
        locationlbl.adjustsFontForContentSizeCategory = true
        locationlbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: 30)
        directionsBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        directionsBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 30)
        routeBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        routeBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 30)
        routeBtn.titleLabel?.numberOfLines = 0
        updateLocationLabelText()
        updateLocationContainerViewHeight()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let strongSelf = self else {
                return
            }
            strongSelf.mapView?.frame = CGRect(x: strongSelf.mapViewContainer.bounds.origin.x,
                                               y: strongSelf.mapViewContainer.bounds.origin.y,
                                               width: strongSelf.mapViewContainer.bounds.width,
                                               height: strongSelf.mapViewContainer.bounds.height)
        }, completion: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.mapView?.setupMapForDarkMode()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        self.directionsBtn.accessibilityIdentifier = "btn_directions"
        self.routeBtn.accessibilityIdentifier = "btn_route"

    }

    func setupMap(latitude: Double,
                  longitude: Double,
                  locationName: String,
                  locationAddress: String,
                  markerTintColor: UIColor,
                  mapInteractionEnabled: Bool,
                  showDirectionsBtn: Bool) {
        self.longitude = longitude
        self.latitude = latitude
        self.locationAddress = locationAddress
        self.tintColor = markerTintColor
        self.locationName = locationName
        self.mapInteractionEnabled = mapInteractionEnabled
        self.setupFinished = true
        self.showDirectionsBtn = showDirectionsBtn
        
        if self.readyToDisplay {
            self.displayMap(latitude: self.latitude, longitude: self.longitude, locationName: self.locationName, locationAddress: self.locationAddress, markerTintColor: self.tintColor)
        }
    }
    
    
    func displayMap(latitude: Double,
                  longitude: Double,
                  locationName: String,
                  locationAddress: String,
                  markerTintColor: UIColor){
        
        
        // handle directionsBtn and routeBtn
        if self.showDirectionsBtn {
            self.directionsBtn.isHidden = false
            self.directionsBtn.setTitle(LocalizationKeys.SCEventDetailMapVC.e006EventGetDirections.localized(), for: .normal)
            self.directionsBtn.setTitleColor(tintColor, for: .normal)
            self.routeBtn.isHidden = true
            self.routeBtnWidthConstraint.constant = 0

        } else {
            self.directionsBtn.isHidden = true
            self.routeBtn.isHidden = false
            self.routeBtn.setTitle(LocalizationKeys.SCEventDetailMapVC.e006EventRoute.localized(), for: .normal)
            self.routeBtn.setTitleColor(tintColor, for: .normal)

        }
        
        updateLocationLabelText()
        updateLocationContainerViewHeight()

        if !isFromPoiDetails && !locationAddress.isSpaceOrEmpty(){

            // if there is no address then we will get it from googler
            if locationAddress.isSpaceOrEmpty(){
                self.reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            } else if latitude == 0.0 && longitude == 0.0 {
                self.geocodeCoordinate(addressString: locationAddress)
            }
        }
        
        // select cameraporsition and add marker
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoomFactor)
        self.marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.marker.icon = GMSMarker.markerImage(with: markerTintColor)
        
        self.marker.title = locationName
        if self.mapView == nil {
            self.mapView = GMSMapView.map(withFrame: mapViewContainer.bounds, camera: camera)
            self.mapView!.delegate = self
            self.mapView!.isUserInteractionEnabled = self.mapInteractionEnabled
            self.mapView!.isBuildingsEnabled = true
            self.marker.map = mapView
            
            self.mapView?.setupMapForDarkMode()
            self.mapViewContainer.addSubview(mapView!)

        } else {
            let update = GMSCameraUpdate.setCamera(camera)
            self.mapView?.moveCamera(update)
        }
        
    }
    
    func updateLocationLabelText(){
        let locationText = locationName.count > 0 ? "\(locationName)\n\(locationAddress)" : locationAddress
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0;
        let attributedString = NSMutableAttributedString(string: locationText, attributes: [.paragraphStyle: paragraphStyle])
        _ = attributedString.setAsBoldFont(textToFind: locationName, fontSize: self.locationlbl.font.pointSize)
        locationlbl.attributedText = attributedString
        
    }
    
    func updateLocationContainerViewHeight() {
        if !routeBtn.isHidden{
            locationLblHeight = locationlbl.text!.estimatedHeight(withConstrainedWidth: self.locationViewContainer.frame.width - (self.routeBtn.frame.width + (!isFromPoiDetails ? 20 : 40)), font: self.locationlbl.font)
        } else {
            locationLblHeight = locationlbl.text!.estimatedHeight(withConstrainedWidth: self.locationViewContainer.frame.width - (!isFromPoiDetails ? 20 : 40), font: self.locationlbl.font)
        }

        if isFromPoiDetails && locationAddress.isSpaceOrEmpty(){
            self.locationViewContainer.isHidden = true
            locationViewContainerHeightConstraint.constant = 0

        }else{
            self.locationViewContainer.isHidden = false
            locationViewContainerHeightConstraint.constant = locationLblHeight + 10
        }
    }
        
    override func viewDidLayoutSubviews(){
        self.mapView?.frame = mapViewContainer.bounds
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoomFactor)
        let update = GMSCameraUpdate.setCamera(camera)
        self.mapView?.moveCamera(update)
    }

    private func geocodeCoordinate( addressString : String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?.first {
                    let location = placemark.location!
                    
                    self.longitude = location.coordinate.longitude
                    self.latitude = location.coordinate.latitude

                    let camera = GMSCameraPosition.camera(withLatitude: self.latitude, longitude: self.longitude, zoom: self.zoomFactor)
                    let update = GMSCameraUpdate.setCamera(camera)
                    self.mapView?.moveCamera(update)
                    self.marker.position = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                    return
                }
            } else {
                SCDataUIEvents.postNotification(for: .noLatLongFound)
            }
        }
    }

    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            
            self.locationAddress = lines.joined(separator: ", ")
            self.locationlbl.text = self.locationAddress
            
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func directionsBtnWasPressed(_ sender: Any) {
//        self.delegate?.directionsBtnWasPressed(latitude: self.latitude, longitude: self.longitude, address: self.locationAddress)
        self.openMaps(latitude: self.latitude, longitude: self.longitude, title: self.locationAddress)
    }
    
    @objc func mapViewWasPressed() {
        self.delegate?.mapWasTapped(latitude: self.latitude, longitude: self.longitude, zoomFactor: self.zoomFactor, address: self.locationAddress)
   }

    //
    // Delegates
    //
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.delegate?.mapWasTapped(latitude: self.latitude, longitude: self.longitude, zoomFactor: self.zoomFactor, address: self.locationAddress)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    @IBAction func didTapDissmissButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func routeBtnWasPressed(_ sender: Any) {
        self.openMaps(latitude: self.latitude, longitude: self.longitude, title: self.locationAddress)
    }
    
    func openMaps(latitude: Double, longitude: Double, title: String?) {
        let application = UIApplication.shared
        let coordinate = "\(latitude),\(longitude)"
        let encodedTitle = title?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let handlers = [
            (LocalizationKeys.SCEventDetailMapVC.e006EventAppleMaps.localized(), "http://maps.apple.com/?q=\(encodedTitle)&ll=\(coordinate)"),
            (LocalizationKeys.SCEventDetailMapVC.e006EventGoogleMaps.localized(), "comgooglemaps://?q=\(coordinate)")
        ]
            .compactMap { (name, address) in URL(string: address).map { (name, $0) } }
            .filter { (_, url) in application.canOpenURL(url) }
        
        guard handlers.count > 0 else {
            self.showUIAlert(with: LocalizationKeys.SCEventDetailMapVC.e006EventNoMapFoundText.localized())
            return
        }
        
        if handlers.count == 1, let url = handlers.first?.1 {
            application.open(url, options: [:])
        } else {
            let alert = UIAlertController(title: LocalizationKeys.SCEventDetailMapVC.e006EventRoutingOptions.localized(), message: LocalizationKeys.SCEventDetailMapVC.e006EventRoutingOptionsMsgText.localized(), preferredStyle: .actionSheet)
            handlers.forEach { (name, url) in
                alert.addAction(UIAlertAction(title: name, style: .default) { _ in
                    application.open(url, options: [:])
                })
            }
            alert.addAction(UIAlertAction(title: LocalizationKeys.SCEventDetailMapVC.e006EventBtnCancel.localized(), style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension GMSCameraUpdate {
    
    static func fit(coordinate: CLLocationCoordinate2D, radius: Double) -> GMSCameraUpdate {
        var leftCoordinate = coordinate
        var rigthCoordinate = coordinate
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        let span = region.span
        
        leftCoordinate.latitude = coordinate.latitude - span.latitudeDelta
        leftCoordinate.longitude = coordinate.longitude - span.longitudeDelta
        rigthCoordinate.latitude = coordinate.latitude + span.latitudeDelta
        rigthCoordinate.longitude = coordinate.longitude + span.longitudeDelta
        
        let bounds = GMSCoordinateBounds(coordinate: leftCoordinate, coordinate: rigthCoordinate)
        let update = GMSCameraUpdate.fit(bounds, withPadding: -15.0)
        
        return update
    }

}



