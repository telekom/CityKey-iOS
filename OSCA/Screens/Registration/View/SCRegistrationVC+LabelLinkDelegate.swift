//
//  SCRegistrationVC+LabelLinkDelegate.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 27.03.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCRegistrationVC: LabelLinkDelegate {
    
    func linkWasTapped(label: SCLabelWithLinks) {
        debugPrint("linkWasTapped")
        
        switch label {
        case self.privacyLabel:
            self.presenter.dataPrivacyLinkWasPressed()
        default:
            debugPrint("SCRegistrationVC: unknown label has tapped a link")
        }
    }
    
    func baseTextWasTapped(label: SCLabelWithLinks) {
        debugPrint("baseTextWasTapped")
        
        switch label {
        case self.privacyLabel:
            self.presenter.privacyWasPressed()
        default:
            debugPrint("SCRegistrationVC: unknown label has tapped a link")
        }
    }
    
    internal func configureLinksInLabels() {
        debugPrint("configureLinksInLabels")
        self.privacyLabel.configureText(baseText: "r_001_registration_label_agreement_abstract".localized(),
                                        linkText: "r_001_registration_label_agreement_privacy".localized())
        
        self.privacyLabel.labelLinkDelegate = self
        
        self.privacyView.accessibilityTraits = .staticText
        self.privacyView.accessibilityLabel = self.privacyLabel.text
        self.privacyView.accessibilityLanguage = SCUtilities.preferredContentLanguage()

    }
}
