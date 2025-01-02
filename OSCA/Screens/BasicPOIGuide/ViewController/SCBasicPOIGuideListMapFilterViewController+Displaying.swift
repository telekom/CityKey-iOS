//
//  SCBasicPOIGuideListMapFilterViewController+Displaying.swift
//  OSCA
//
//  Created by A106551118 on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCBasicPOIGuideListMapFilterViewController: SCBasicPOIGuideListMapFilterDisplaying {
    
    func setupUI(with navigationTitle: String) {
        
        self.navigationItem.title = navigationTitle
        self.navigationItem.backBarButtonItem?.title = ""
        
        self.categoryViewContainer.addBorder()
        self.categoryViewContainer.addCornerRadius()
                
        self.locateMeBtn.clipsToBounds = true
        self.locateMeBtn.layer.cornerRadius = self.locateMeBtn.frame.size.width/2
        
        self.errorLabel.adaptFontSize()
        self.errorLabel.text = LocalizationKeys.SCBasicPOIGuideCategorySelectionVCDisplaying.poi002ErrorText.localized()
        self.retryButton.setTitle(" " + LocalizationKeys.SCBasicPOIGuideCategorySelectionVCDisplaying.e002PageLoadRetry.localized(), for: .normal)
        self.retryButton.setTitleColor(kColor_cityColor, for: .normal)
        self.retryButton.titleLabel?.adaptFontSize()
        self.retryButton.setImage(UIImage(named: LocalizationKeys.SCBasicPOIGuideCategorySelectionVCDisplaying.actionResendEmail)?.maskWithColor(color: kColor_cityColor), for: .normal)
        
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .gray
        }
        
        self.setVisibilityOfListMapFilter()
        
    }
    
    func updateCategory(){
        categoryIcon.image = UIImage(named: "icon-action-filter-default")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        categoryLbl.text = SCUserDefaultsHelper.getPOICategory() ?? ""
        categoryViewContainer.accessibilityLabel = SCUserDefaultsHelper.getPOICategory() ?? ""
    }
    
    func loadPois(_ poiItems: [POIInfo]){
        self.poiItems = poiItems
        if !self.isListSelected{
            self.showPOIItems(self.poiItems!)
        }
        else{
            self.listTableView.reloadData()
        }
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }

    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func present(viewController: UIViewController) {
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        self.present(viewController, animated: true)
    }

    func showPOIOverlay() {
        self.setupPOIOverlayView()
        self.poiOverlayView.isHidden = false
    }
    
    func hidePOIOverlay() {
        self.poiOverlayView.isHidden = true
    }
    
    func showLocationFailedMessage(messageTitle: String, withMessage: String) -> Void  {
        let alertController = UIAlertController(title: messageTitle as String, message: withMessage as String, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: LocalizationKeys.SCBasicPOIGuideCategorySelectionVCDisplaying.c001CitiesDialogGpsBtnCancel.localized(), style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: LocalizationKeys.SCBasicPOIGuideCategorySelectionVCDisplaying.c001CitiesDialogGpsBtnOk.localized(), style: .default) { (action:UIAlertAction!) in
            
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
    
    func loadCategoryFTUFlow() {
        if SCUserDefaultsHelper.getPOICategory() == nil {
            self.presenter.categoryWasPressed()
        }
    }
    
    func drawImageWithCategory(icon: UIImage, image: UIImage) -> UIImage {

        let imgView = UIImageView(image: image)
//        imgView.frame = CGRect(x: 0, y: 0, width: 30, height: 45)

        let picImgView = UIImageView(image: icon)
        picImgView.frame = CGRect(x: 0, y: 5, width: 24, height: 24)
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
}
