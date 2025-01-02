//
//  SCDefectReporterFormViewController.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 09/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import GoogleMaps

class SCDefectReporterFormViewController: UIViewController {

    public var presenter: SCDefectReporterFormPresenting!

    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var contentScrollview: UIScrollView!
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var changeLocationBtn: SCCustomButton!
    @IBOutlet weak var sendReportBtn: SCCustomButton!
    @IBOutlet weak var changeLocationView: UIView!
    @IBOutlet weak var changeLocationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var issueDetailView: UIView!
    @IBOutlet weak var issueDetailLabel: UILabel!
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet weak var addPhotoView: UIView!
    @IBOutlet weak var addPhotoTitleLabel: UILabel!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var defectPhotoImageView: UIImageView!
    @IBOutlet weak var addPhotoContainerView: UIView!
    @IBOutlet weak var addPhotoContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deletePhotoBtn: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var topSeparatorReporterDetailView: UIView!
    @IBOutlet weak var topSeparatorReporterDetailViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reporterDetailView: UIView!
    @IBOutlet weak var reporterDetailLabel: UILabel!
    @IBOutlet weak var reporterDetailStackView: UIStackView!

    @IBOutlet weak var termsValidationStateLabel: UILabel!
    @IBOutlet weak var termsValidationStateView: UIImageView!
    @IBOutlet weak var termsBtn: UIButton!
    @IBOutlet weak var termsLabel: SCTopAlignLabel!
    @IBOutlet weak var termsView: UIView!

    @IBOutlet weak var yourConcernContainerView: UIView!
    @IBOutlet weak var yourConcernContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var firstNameContainerView: UIView!
    @IBOutlet weak var firstNameContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lastNameContainerView: UIView!
    @IBOutlet weak var lastNameContainerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var wasteBinIDContainerView: UIView!
    @IBOutlet weak var wasteBinIDContainerViewHeight: NSLayoutConstraint!
    
    // This constraint ties an element at zero points from the bottom layout guide
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?

    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var noteDescTxtV: UITextView!
    @IBOutlet weak var noteViewHeight: NSLayoutConstraint!
    @IBOutlet weak var issueDetailLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var issueDetailLabelBottomConstraint: NSLayoutConstraint!
    
    var txtfldYourConcern : SCTextViewComponent?
    var txtfldEmail : SCTextfieldComponent?
    var txtfldFirstName : SCTextfieldComponent?
    var txtfldLastName : SCTextfieldComponent?
    var txtfldWasteBinID : SCTextfieldComponent?
    var activeComponent: SCTextfieldComponent?
    var activeTxvComponent: SCTextViewComponent?

    private let keyboardOffsetSpace : CGFloat = 35.0
    var keyboardHeight : CGFloat = 0.0
    var zoomFactorMax : Float = 15.0
    var zoomFactorMin : Float = 10.0
    var addPhotoContainerHeight : CGFloat = 135.0
    var textFieldContainerHeight : CGFloat = 94.0
    var textViewContainerHeight : CGFloat = 120.0

    var mapView : GMSMapView?
    var completionAfterDismiss: (() -> Void)? = nil
    
    var imagePicker: SCImagePicking!
    var defectImageData: Data = Data()
    var subCategory: SCModelDefectSubCategory?
    var category: SCModelDefectCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shouldNavBarTransparent = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)

        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        setup()
        
        self.configureMap()
        
        let termsTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.termsViewWasPressed))
        self.termsView.addGestureRecognizer(termsTapGesture)

        let addPhotoTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.addPhotoBtnWasPressed(_:)))
        self.addPhotoView.addGestureRecognizer(addPhotoTapGesture)
                
        self.imagePicker =  SCImagePicker.instance(presentationController: self, delegate: self)

        self.handleDynamicTypeChange()
                
        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
        contentScrollview.isDirectionalLockEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
        self.refreshNavigationBarStyle()
    }

    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter.viewDidAppear()
        // SMARTC-18952 Prefill email address from Citykey profile only if the user is logged in
        self.setupPrefilledEmail()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if let termsimage = self.termsBtn?.image(for: .normal){
                    self.termsBtn?.setImage(termsimage.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
                }
            }
        }
        
        self.mapView?.setupMapForDarkMode()

    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        
        // Setup Dynamic font for Email
        txtfldEmail?.textField.adjustsFontForContentSizeCategory = true
        txtfldEmail?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        txtfldEmail?.placeholderLabel.adjustsFontForContentSizeCategory = true
        txtfldEmail?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        txtfldEmail?.errorLabel.adjustsFontForContentSizeCategory = true
        txtfldEmail?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for txtfldFirstName
        txtfldFirstName?.textField.adjustsFontForContentSizeCategory = true
        txtfldFirstName?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        txtfldFirstName?.placeholderLabel.adjustsFontForContentSizeCategory = true
        txtfldFirstName?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        txtfldFirstName?.errorLabel.adjustsFontForContentSizeCategory = true
        txtfldFirstName?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for txtfldLastName
        txtfldLastName?.textField.adjustsFontForContentSizeCategory = true
        txtfldLastName?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        txtfldLastName?.placeholderLabel.adjustsFontForContentSizeCategory = true
        txtfldLastName?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        txtfldLastName?.errorLabel.adjustsFontForContentSizeCategory = true
        txtfldLastName?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for txtfldYourConcern
        txtfldYourConcern?.textView.adjustsFontForContentSizeCategory = true
        txtfldYourConcern?.textView.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 24)
        txtfldYourConcern?.placeholderLabel.adjustsFontForContentSizeCategory = true
        txtfldYourConcern?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 24)
        txtfldYourConcern?.errorLabel.adjustsFontForContentSizeCategory = true
        txtfldYourConcern?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        txtfldYourConcern?.characterCountLabel.adjustsFontForContentSizeCategory = true
        txtfldYourConcern?.characterCountLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 23)
        
        // Setup Dynamic font for txtfldWasteBinID
        txtfldWasteBinID?.textField.adjustsFontForContentSizeCategory = true
        txtfldWasteBinID?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 23)
        txtfldWasteBinID?.placeholderLabel.adjustsFontForContentSizeCategory = true
        txtfldWasteBinID?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 22)
        txtfldWasteBinID?.errorLabel.adjustsFontForContentSizeCategory = true
        txtfldWasteBinID?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)

        // Setup Dynamic font for Privacy info text
        termsValidationStateLabel.adjustsFontForContentSizeCategory = true
        termsValidationStateLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        termsLabel.adjustsFontForContentSizeCategory = true
        termsLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        locationTitleLabel.adjustsFontForContentSizeCategory = true
        locationTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 21, maxSize: nil)
        
        changeLocationBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        changeLocationBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 30)
        
        sendReportBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        sendReportBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
        
        addPhotoTitleLabel.adjustsFontForContentSizeCategory = true
        addPhotoTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        
        addPhotoLabel.adjustsFontForContentSizeCategory = true
        addPhotoLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 12, maxSize: 25)
        
        issueDetailLabel.adjustsFontForContentSizeCategory = true
        issueDetailLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 21, maxSize: nil)
        
        reporterDetailLabel.adjustsFontForContentSizeCategory = true
        reporterDetailLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 21, maxSize: nil)
        
        noteLabel.adjustsFontForContentSizeCategory = true
        noteLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 21, maxSize: nil)
        
        noteDescTxtV.adjustsFontForContentSizeCategory = true
        noteDescTxtV.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15, maxSize: nil)
     
    }
    
    
    func configureMap(){
                
        // Create a map.
        // select cameraporsition and add marker
        let latitude = self.presenter.getDefectLocation().coordinate.latitude
        let longitude = self.presenter.getDefectLocation().coordinate.longitude
        let camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: zoomFactorMax)

        if self.mapView == nil {
            let map = GMSMapView(frame: mapViewContainer.bounds, camera: camera)
            mapView = map

            self.mapView!.translatesAutoresizingMaskIntoConstraints = false
            self.mapView!.isMyLocationEnabled = true
            self.mapView!.isUserInteractionEnabled = true
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
            
            self.addDefectLocationMarker(latitude: latitude, longitude: longitude)
            
        } else {
            self.mapView?.animate(to: camera)
        }
    }
    
    func addDefectLocationMarker(latitude: CLLocationDegrees,
                                 longitude: CLLocationDegrees){
        self.mapView?.clear()
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.icon = GMSMarker.markerImage(with: kColor_cityColor)
        marker.title = title
        marker.accessibilityLabel = title
        marker.title?.accessibilityElementsHidden = true
        marker.icon?.accessibilityElementsHidden = true
        marker.map = mapView
    }
    /**
     *
     * Handle Keyboard
     *
     */
    @objc func keyboardWillShow(notification: Notification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight: CGFloat = keyboardSize.height
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.contentScrollview?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }, completion: nil)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        let info = notification.userInfo!
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.contentScrollview?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }, completion: nil)
    }
    
    /**
     *
     * Method to scroll to a component
     */
    
    func scrollComponentToVisibleArea(component: SCTextfieldComponent) {
        var navBarHeight : CGFloat = 0.0
        var aRect : CGRect = self.contentScrollview.bounds
        
        if let navigationController = self.navigationController {
            navBarHeight = navigationController.navigationBar.frame.size.height + navigationController.navigationBar.frame.origin.y
        }
        
        aRect.size.height -= self.keyboardHeight
        aRect.size.height += navBarHeight
        let fieldPoint = CGPoint(x: 0.0 , y: component.textfieldFrame().origin.y + component.textfieldFrame().size.height)
        if !(aRect.contains(fieldPoint))
        {
            self.contentScrollview.setContentOffset(CGPoint(x:0, y:component.textfieldFrame().origin.y - aRect.size.height + keyboardOffsetSpace + component.textfieldFrame().size.height  ), animated: true)
            
        }
    }
    
    func scrollComponentToVisibleArea(component: SCTextViewComponent) {
        var navBarHeight : CGFloat = 0.0
        var aRect : CGRect = self.contentScrollview.bounds
        
        if let navigationController = self.navigationController {
            navBarHeight = navigationController.navigationBar.frame.size.height + navigationController.navigationBar.frame.origin.y
        }
        
        aRect.size.height -= self.keyboardHeight
        aRect.size.height += navBarHeight
        let fieldPoint = CGPoint(x: 0.0 , y: component.textfieldFrame().origin.y + component.textfieldFrame().size.height)
        if !(aRect.contains(fieldPoint))
        {
            self.contentScrollview.setContentOffset(CGPoint(x:0, y:component.textfieldFrame().origin.y - aRect.size.height + keyboardOffsetSpace + component.textfieldFrame().size.height  ), animated: true)
            
        }
    }
    
    /**
     *
     * Method to get referenced of the embedded viewController
     *
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let textfield as SCTextfieldComponent:
            textfield.delegate = self
            
            self.txtfldEmail = self.presenter.configureField(textfield, identifier: segue.identifier, type: .email, autocapitalizationType: .none) as? SCTextfieldComponent ?? self.txtfldEmail
            self.txtfldFirstName = self.presenter.configureField(textfield, identifier: segue.identifier, type: .fname, autocapitalizationType: .none) as? SCTextfieldComponent ?? self.txtfldFirstName
            self.txtfldLastName = self.presenter.configureField(textfield, identifier: segue.identifier, type: .lname, autocapitalizationType: .none) as? SCTextfieldComponent ?? self.txtfldLastName
            self.txtfldWasteBinID = self.presenter.configureField(textfield, identifier: segue.identifier, type: .wastebinid, autocapitalizationType: .none) as? SCTextfieldComponent ?? self.txtfldWasteBinID

            self.setTextFieldContainerViewHeight()
            
        case let textView as SCTextViewComponent:
            textView.delegate = self
            
            self.txtfldYourConcern = self.presenter.configureField(textView, identifier: segue.identifier, type: .yourconcern, autocapitalizationType: .none) as? SCTextViewComponent ?? self.txtfldYourConcern
            
            self.yourConcernContainerView.isHidden = !(txtfldYourConcern?.isEnabled() ?? false) ? true : false
            self.yourConcernContainerViewHeight.constant = !(txtfldYourConcern?.isEnabled() ?? false) ? 0 : textViewContainerHeight
        default:
            break
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupPrefilledEmail(){
        self.txtfldEmail?.text = !(self.txtfldEmail?.text!.isEmpty)! ? self.getValue(for: .email) : self.presenter.getProfileData()?.email
        self.txtfldEmail?.placeholderLabel?.text = self.txtfldEmail?.placeholderText
        self.txtfldEmail?.placeholderLabel?.isHidden = self.txtfldEmail?.text?.isEmpty ?? true
        self.presenter.updateSendReportBtnState()
    }
    
    func deleteSelectedImage() {
        self.defectPhotoImageView.image = nil
        self.handleImageSelection(isDefectImageVisible: true, isAddPhotoBtnVisible: false, isDeletePhotoBtnVisible: true, addPhotoViewBorder: 1)
        UIAccessibility.post(notification: .layoutChanged, argument: addPhotoBtn)
    }
    
    func handleImageSelection(isDefectImageVisible: Bool, isAddPhotoBtnVisible: Bool, isDeletePhotoBtnVisible: Bool, addPhotoViewBorder: CGFloat){
        self.defectPhotoImageView.isHidden = isDefectImageVisible
        self.addPhotoLabel.isHidden = isAddPhotoBtnVisible
        self.addPhotoBtn.isHidden = isAddPhotoBtnVisible
        self.deletePhotoBtn.isHidden = isDeletePhotoBtnVisible
        self.addPhotoView.addBorder(width: addPhotoViewBorder, color: kColor_cityColor)

    }
    
    @objc func termsViewWasPressed() {
        self.presenter.termsWasPressed()
    }
    
    @IBAction func termsBtnWasPressed(_ sender: Any) {
        self.presenter.termsWasPressed()
    }
    
    @IBAction func addPhotoBtnWasPressed(_ sender: UIButton) {
        self.handleImageSelection(isDefectImageVisible: true, isAddPhotoBtnVisible: true, isDeletePhotoBtnVisible: true, addPhotoViewBorder: 1)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func deletePhotoBtnWasPressed(_ sender: UIButton) {
        self.deleteSelectedImage()
    }
        
    @IBAction func changeLocationBtnWasPressed(_ sender: UIButton) {
        SCUserDefaultsHelper.setDefectLocationStatus(status: true)
        self.presenter.changeLocationBtnWasPressed()
    }
    
    @IBAction func sendReportBtnWasPressed(_ sender: UIButton) {
        let defectLocation = SCUserDefaultsHelper.getDefectLocation().coordinate
        reverseGeocodeWith(coordinate: CLLocationCoordinate2D(latitude: defectLocation.latitude, longitude: defectLocation.longitude)) { locationDetails in
            self.presenter.sendReportBtnWasPressed(defectLocation: locationDetails)
        }
    }
    
    func reverseGeocodeWith(coordinate: CLLocationCoordinate2D, completionHandler: ((LocationDetails?) -> Void)?) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let places = response?.results() {
                if let address = places.first {
                    completionHandler?(LocationDetails(locationAddress: address.lines?.first,
                                                       streetName: address.thoroughfare?.after(first: " "),
                                                       houseNumber: address.thoroughfare?.before(first: " "),
                                                       postalCode: address.postalCode))
                } else {
                    completionHandler?(nil)
                }
            } else {
                completionHandler?(nil)
            }
        }
    }

}

// MARK: - GMSMapViewDelegate

extension SCDefectReporterFormViewController: GMSMapViewDelegate {

}
