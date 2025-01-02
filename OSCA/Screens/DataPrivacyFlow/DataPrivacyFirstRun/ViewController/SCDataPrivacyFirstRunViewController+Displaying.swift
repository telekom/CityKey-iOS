//
//  SCDataPrivacyFirstRunViewController+Displaying.swift
//  OSCA
//
//  Created by Bhaskar N S on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//
import UIKit
extension SCDataPrivacyFirstRunViewController : SCDataPrivacyFirstRunDisplay {
    
    func setupUI(navigationTitle: String, description: String) {
        
        self.navigationItem.title = navigationTitle
        
        
        let descriptionFormatted = description.replacingOccurrences(of: "%s", with: "%@")
        let descriptionAttrText = NSMutableAttributedString(string: String(format: descriptionFormatted, LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuDpnLink.localized(),
                                                                           LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuContinueLink.localized()))
        _ = descriptionAttrText.setTextColor(textToFind: LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuDpnLink.localized(),
                                             color: UIColor.ausweisBlue)
        _ = descriptionAttrText.setTextColor(textToFind: LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuContinueLink.localized(),
                                             color: UIColor.oscaColor)
        _ = descriptionAttrText.setAsUnderscore(textToFind: LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuDpnLink.localized())
        _ = descriptionAttrText.setAsUnderscore(textToFind: LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuContinueLink.localized())
        self.descriptionLabel.attributedText = descriptionAttrText
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnDescriptionLabel(gesture:)))
        self.descriptionLabel.isUserInteractionEnabled = true
        self.descriptionLabel.addGestureRecognizer(tapAction)
        
    }

    @objc func didTapOnDescriptionLabel(gesture: UITapGestureRecognizer) {
        
        if gesture.didTapAttributedTextInLabel(label: self.descriptionLabel,
                                               targetText: LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuDpnLink.localized()) {
            presenter.dataPrivacyNoticeLinkPressed()
        }
        else if gesture.didTapAttributedTextInLabel(label: self.descriptionLabel, targetText: LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuContinueLink.localized()) {
            presenter.acceptSelectedLinkPressed()
        }
    }
    
    func preventSwipeToDismiss() {
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func navigateTo(_ controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}
