//
//  SCBasicPOIGuideCategorySelectionVC+Displaying.swift
//  OSCA
//
//  Created by A106551118 on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCBasicPOIGuideCategorySelectionVC: SCBasicPOIGuideDisplaying {
    
    func setupUI() {
        self.navigationItem.title = "poi_002_title".localized()
        self.overlayView.isHidden = true
        
        self.errorLabel.adaptFontSize()
        self.errorLabel.text = "poi_002_error_text".localized()
        self.retryButton.setTitle(" " + "e_002_page_load_retry".localized(), for: .normal)
        self.retryButton.setTitleColor(kColor_cityColor, for: .normal)
        self.retryButton.titleLabel?.adaptFontSize()
        self.retryButton.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: kColor_cityColor), for: .normal)
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .gray
        }
    }
    
    func updateAllPOICategoryItems(with categoryItems: [POICategoryInfo]) {
        self.categoryTableViewController?.categoryItems = categoryItems
        self.categoryTableViewController?.tableView.reloadData()
    }
    
    func showPOICategoryActivityIndicator(for categoryName: String) {
        self.categoryTableViewController?.showPOICategoryActivityIndicator(for: categoryName)
    }
    
    func hidePOICategoryActivityIndicator() {
        self.categoryTableViewController?.hidePOICategoryActivityIndicator()
    }
    
    func showPOICategoryMarker(for categoryName: String, color: UIColor) {
        self.categoryTableViewController?.showPOICategoryMarker(for: categoryName, color: color)
    }
        
    func dismiss() {
        if SCUserDefaultsHelper.getPOICategory() != nil{
            self.dismiss(animated: true)
            completionAfterDismiss?()
        }else{
            self.dismissCategory()
        }
    }
    
    func dismissCategory() {
        SCUtilities.dismissAnyPresentedViewController { () -> Void? in
            self.navigationController?.popToRootViewController(animated: true)
            let tabBarController = SCUtilities.topViewController() as? UITabBarController
            if let indexForServiceTab = SCUtilities.indexForServiceController() {
                tabBarController?.selectedIndex = indexForServiceTab
                let selectedViewController = tabBarController?.selectedViewController as? UINavigationController
                let servicesViewController = selectedViewController?.hasViewController(ofKind: SCServicesViewController.self) as! SCServicesViewController

                selectedViewController?.popToViewController(servicesViewController, animated: true)

            }
            return nil
        }
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

    func showOverlayWithActivityIndicator() {
        self.activityIndicator.isHidden = false
        self.overlayView.isHidden = false
        self.errorLabel.isHidden = true
        self.retryButton.isHidden = true
    }

    func showOverlayWithGeneralError() {
        self.activityIndicator.isHidden = true
        self.errorLabel.isHidden = false
        self.retryButton.isHidden = false
        self.overlayView.isHidden = false
    }

    func hideOverlay() {
        self.overlayView.isHidden = true
    }
}
