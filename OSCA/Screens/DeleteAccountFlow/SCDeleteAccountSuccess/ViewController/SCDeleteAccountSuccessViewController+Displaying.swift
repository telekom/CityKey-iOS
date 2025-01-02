//
//  SCDeleteAccountSuccessViewController+Displaying.swift
//  OSCA
//
//  Created by Bhaskar N S on 26/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCDeleteAccountSuccessViewController: SCDeleteAccountSuccessDisplaying {
    func setupTitleLabel(text: String) {
        self.titleLabel.text = text
        self.titleLabel.adaptFontSize()
        
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 20)
    }
    
    func setupSubtitleLabel(text: String) {
        self.subtitleLabel.text = text
        self.subtitleLabel.adaptFontSize()
        subtitleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 15, maxSize: 17)
    }
    
    func setupDescriptionLabel(text: String) {
        self.descriptionLabel.text = text
        self.descriptionLabel.adaptFontSize()
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 15, maxSize: 17)
    }
    
    func setupNavigationBar(with title: String) {
        self.navigationItem.title = title
        self.navigationItem.hidesBackButton = true
    }
    
    func setupOkButton(with title: String) {
        self.okButton.customizeBlueStyle()
    }
    
    func dismissDeleteAccountFlow() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
}
