//
//  SCBasicPOIGuideDetailViewController+Displaying.swift
//  OSCA
//
//  Created by A106551118 on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCBasicPOIGuideDetailViewController: SCBasicPOIGuideDetailDisplaying {
    
    func setupUI(navTitle: String,
                 title: String,
                 description: String,
                 address: String,
                 categoryName: String,
                 cityId: Int,
                 distance: Int,
                 icon: SCImageURL?,
                 latitude: Double,
                 longitude: Double,
                 openHours: String,
                 id: Int,
                 subtitle: String,
                 url: String) {
        
        self.navigationItem.title = navTitle
        let backButton = UIBarButtonItem()
        backButton.title = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationItem.rightBarButtonItem = presenter?.getShareBarButton()

        if latitude == 0.0 && longitude == 0.0 && address.count == 0 {
            self.mapHeightConstraint.constant = 0.0
            self.tapOnInfolbl.isHidden = true
        } else {
            self.mapViewController?.isFromPoiDetails = true
            self.mapViewController?.setupMap(latitude: latitude,
                                             longitude: longitude,
                                             locationName: "",
                                             locationAddress: address,
                                             markerTintColor: kColor_cityColor,
                                             mapInteractionEnabled: false,
                                             showDirectionsBtn: false)
            
            self.mapHeightConstraint.constant = address.isSpaceOrEmpty() ? 130 : (mapViewController?.locationLblHeight ?? 0) + 150
        }
    
        self.topSpaceFromMapConstraint.isActive = address.count == 0 ? true : false
        
        self.categoryLabel.attributedText = title.applyHyphenation()
        self.subtitleLabel.text = subtitle
        let attrString =  description.htmlAttributedString?.trimmedAttributedString(set: .whitespacesAndNewlines)
        let htmlAttributedString = NSMutableAttributedString(attributedString: attrString!)
        print("**attrString", attrString!)
        print("**htmlAttributedString", htmlAttributedString)
//        htmlAttributedString.replaceFont(with: self.descriptionTxtV.font!, color: self.descriptionTxtV.textColor!)
//        self.descriptionTxtV.attributedText = htmlAttributedString
//        self.descriptionTxtV.linkTextAttributes = [.foregroundColor: kColor_cityColor]
//        self.descriptionTxtV.textContainerInset = UIEdgeInsets.zero
//        self.descriptionTxtV.textContainer.lineFragmentPadding = 0
        
        descriptionTxtV.loadWebView(with: description)
        let attrStringOH =  openHours.htmlAttributedString?.trimmedAttributedString(set: .whitespacesAndNewlines)
        let htmlAttributedStringOH = NSMutableAttributedString(attributedString: attrStringOH!)
        htmlAttributedStringOH.replaceFont(with: self.openHoursTxtV.font!, color: self.openHoursTxtV.textColor!)
        self.openHoursTxtV.attributedText = htmlAttributedStringOH
        self.openHoursTxtV.linkTextAttributes = [.foregroundColor: kColor_cityColor]
        self.openHoursTxtV.textContainerInset = UIEdgeInsets.zero
        self.openHoursTxtV.textContainer.lineFragmentPadding = 0
        
//        var heightDescTitle =  self.descriptionTxtV.calculateViewHeightWithCurrentWidth()
//
//        if !self.websiteLabel.text!.isSpaceOrEmpty(){
//            heightDescTitle = CGFloat(Double((descriptionTxtV?.frame.origin.y)! + self.descriptionTxtV.calculateViewHeightWithCurrentWidth()))
//        }else{
//            heightDescTitle = self.descriptionTxtV.calculateViewHeightWithCurrentWidth()
//        }

        self.descriptionTxtV.isHidden = description.isEmpty
        
        var heightOpenHrsTitle = self.openHoursTxtV.calculateViewHeightWithCurrentWidth()
        if !description.isSpaceOrEmpty() {
            heightOpenHrsTitle = CGFloat(Double((openHoursTxtV?.frame.origin.y)! + self.openHoursTxtV.calculateViewHeightWithCurrentWidth()))
        }else{
            heightOpenHrsTitle = self.openHoursTxtV.calculateViewHeightWithCurrentWidth()
        }
        
        openHoursHeightConstraint.constant = !openHours.isSpaceOrEmpty() ?  CGFloat(heightOpenHrsTitle) : 0
        
        self.websiteLabel.text = url
        self.websiteLabel.textColor = kColor_cityColor
        self.imageCategory.image = SCUserDefaultsHelper.setupCategoryIcon(SCUserDefaultsHelper.getPOICategoryGroupIcon() ?? "").maskWithColor(color: kColor_cityColor)
        self.openHoursLbl.isHidden = !self.openHoursTxtV.text!.isSpaceOrEmpty() ? false : true
        self.descriptionLbl.isHidden = !description.isSpaceOrEmpty() ? false : true
        self.websiteLbl.isHidden = !self.websiteLabel.text!.isSpaceOrEmpty() ? false : true
        self.addressLbl.isHidden = !(latitude == 0.0 && longitude == 0.0 && address.count == 0) ? false : true
        self.addressLbl.isHidden = !address.isSpaceOrEmpty() ? false : true
        self.openHoursStack.isHidden = !self.openHoursTxtV.text!.isSpaceOrEmpty() ? false : true
        self.descriptionStack.isHidden = !description.isSpaceOrEmpty() ? false : true
        self.websiteStack.isHidden = !self.websiteLabel.text!.isSpaceOrEmpty() ? false : true
        self.topSpaceFromOpenHoursConstraint.constant = !self.openHoursTxtV.text!.isSpaceOrEmpty() ? 15 : 0
        self.topSpaceFromDescConstraint.constant = !description.isSpaceOrEmpty() ? 15 : 0
        self.topSpaceFromWebsiteConstraint.constant = !self.websiteLabel.text!.isSpaceOrEmpty() ? 15 : 0
        self.addressLblHeightConstraint.constant = !address.isSpaceOrEmpty() ? 18 : 0
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
    

}

