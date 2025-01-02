//
//  SCDataPrivacySettingsViewController+Displaying.swift
//  OSCA
//
//  Created by Bhaskar N S on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCDataPrivacySettingsViewController : SCDataPrivacySettingsDisplay {
    
    func setupUI(navigationTitle: String,
                 title: String,
                 description: String,
                 moengageTitle: String,
                 moengageDescription: String,
                 adjustTitle: String,
                 adjustDescription: String,
                 adjustEnabled: Bool) {
        
        self.navigationItem.title = navigationTitle
        self.titleLabel.attributedText = title.applyHyphenation()
        self.descriptionLabel.attributedText = description.applyHyphenation()
        self.adjustOptionView.permissionSwitch.isOn = adjustEnabled
        self.moengageOptionView.titleLabel.text = moengageTitle
        self.moengageOptionView.descriptionLabel.attributedText = moengageDescription.applyHyphenation()
        self.adjustOptionView.titleLabel.text = adjustTitle
        self.adjustOptionView.descriptionLabel.attributedText = adjustDescription.applyHyphenation()
        self.adjustOptionView.permissionSwitch.isOn = adjustEnabled
        
    }
    
    func preventSwipeToDismiss() {
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
    }
    
    func dismiss() {
                
        self.dismiss(animated: true, completion: nil)
    }
    
    func push(_ controller : UIViewController) {
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func popViewController() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func dismiss(completionHandler: (() -> Void)?) {
        self.dismiss(animated: true, completion: completionHandler)
    }
    
}
