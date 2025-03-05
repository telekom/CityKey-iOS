/*
Created by A106551118 on 07/07/22.
Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, A106551118
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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

