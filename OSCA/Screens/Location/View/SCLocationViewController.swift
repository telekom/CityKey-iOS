/*
Created by Michael on 08.11.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCLocationViewController: UIViewController     {
    
    public var presenter: SCLocationPresenting!
        
    var locationTableViewController : SCLocationSubTableVC?
    
    var presentationMode : SCLocationPresentationMode = .notSignedIn
    
    var completionAfterDismiss: (() -> Void)? = nil
    
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    
    @IBOutlet weak var footerInfoView: UIView!
    @IBOutlet weak var cityInfoLabel: UILabel!
    @IBOutlet var footerInfoViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.shouldNavBarTransparent = false
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
    
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicTypeChange))
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let locationTableViewController as SCLocationSubTableVC:
            locationTableViewController.delegate = self
            self.locationTableViewController = locationTableViewController
            break
        default:
            break
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    // private methods
    private func setupUI() {
        
        self.navigationItem.title = "c_001_cities_title".localized()
        self.cityInfoLabel.text = "c_001_cities_footer_info".localized()
        //self.switchToCitySelectionMode(animated: false)
        //self.activatePresentationMode(self.presentationMode)
        cityInfoLabel.adjustsFontForContentSizeCategory = true
        cityInfoLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 14, maxSize: 24)
    }
    
    @objc func handleDynamicTypeChange(notification: NSNotification) {
        setupUI()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
    
}

// MARK: - SCLocationDisplaying
extension SCLocationViewController: SCLocationDisplaying {
    func configureLocationServiceNotAvailable() {
        self.locationTableViewController?.configureLocationServiceNotAvailable()
    }
    
    func showGeoLocatedCity(for cityId: Int, distance: Double) {
        self.locationTableViewController?.showGeoLocatedCity(for: cityId, distance: distance)
    }
    
        
    func dismiss() {
        self.dismiss(animated: true)
        completionAfterDismiss?()
    }
    
    func updateAllCityItems(with cityItems: [CityLocationInfo]) {
        self.locationTableViewController?.allCityItems = cityItems
        self.locationTableViewController?.reloadData()
        self.footerInfoView.isHidden = cityItems.count <= 3 ? false : true
        
        switch UIScreen.main.bounds.size.height {
        case 568:
            self.footerInfoViewHeightConstraint.constant = self.footerInfoView.isHidden ? 0 : 100
        case 667:
            self.footerInfoViewHeightConstraint.constant = self.footerInfoView.isHidden ? 0 : (UIScreen.main.bounds.size.height * 0.3)
        default:
            self.footerInfoViewHeightConstraint.constant = self.footerInfoView.isHidden ? 0 : (UIScreen.main.bounds.size.height * 0.4)
        }
    }
    
    func updateFavoriteCityItems(with cityItems: [CityLocationInfo]) {
        self.locationTableViewController?.favoriteCityItems = cityItems
        self.locationTableViewController?.reloadData()
    }
    
    func showLocationActivityIndicator(for cityName: String) {
        self.locationTableViewController?.showLocationActivityIndicator(for: cityName)
    }
    
    func hideLocationActivityIndicator() {
        self.locationTableViewController?.hideLocationActivityIndicator()
    }
    
    func searchLocActivityIndicator(show : Bool) {
        self.locationTableViewController?.searchLocActivityIndicator(show: show)
    }

    func showLocationFailedMessage(messageTitle: String, withMessage: String) -> Void  {
        let alertController = UIAlertController(title: messageTitle as String, message: withMessage as String, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "c_001_cities_dialog_gps_btn_cancel".localized(), style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "c_001_cities_dialog_gps_btn_ok".localized(), style: .default) { (action:UIAlertAction!) in
            
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
    
    func showLocationInfoMessage(messageTitle: String, withMessage: String) -> Void  {
        let alertController = UIAlertController(title: messageTitle as String, message: withMessage as String, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "dialog_button_ok".localized(), style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    func showLocationMarker(for cityName : String, color: UIColor) {
        self.locationTableViewController?.showLocationMarker(for: cityName, color: color)
    }
    
    func showCityNotAvailable() {
        self.presenter.loadDefaultCity()
        self.locationTableViewController?.reloadData()
    }
}

// MARK: - SCLocationSubTableVCDelegate
extension SCLocationViewController : SCLocationSubTableVCDelegate {
    
    func determineLocationBtnWasPressed() {
        self.presenter.determineLocationButtonWasPressed()
        // self.searchLocation()
    }
    
    func favDidChange(cityName : String, isFavorite: Bool) {
        self.presenter.favDidChange(cityName: cityName, isFavorite: isFavorite)
    }
    
    func locationWasSelected(cityName: String, cityID : Int) {
        self.presenter.locationWasSelected(cityName: cityName, cityID: cityID)
    }
    
    func isStoredLocationSuggestionAvailable() -> Bool {
        return self.presenter.isStoredLocationSuggestionAvailable()
    }
    
    func storedCityLocation() -> Int? {
        return self.presenter.storedLocationSuggestion()
    }
    
    func storedDistanceToNearestLocation() -> Double? {
        return self.presenter.storedDistanceToNearestLocation()
    }
    
}

// MARK: - SCLocationPresentationMode
extension SCLocationViewController {
    
    func activatePresentationMode(_ mode : SCLocationPresentationMode){
        //TODO: evaluate if this is still relevant
    }
}

extension SCLocationViewController: SCDisplaying {
    func showError(with text: String) {
        self.showUIAlert(with: text)
    }
}
