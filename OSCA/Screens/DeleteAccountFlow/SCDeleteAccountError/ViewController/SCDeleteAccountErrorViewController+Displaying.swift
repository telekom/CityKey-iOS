//
//  SCDeleteAccountErrorViewController+Displaying.swift
//  OSCA
//
//  Created by Bhaskar N S on 26/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCDeleteAccountErrorViewController: SCDeleteAccountErrorDisplaying {
    func setupTitleLabel(with title: String) {
        self.titleLabel.text = title
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
    }
    
    func setupSubtitleLabel(with title: String) {
        self.titleLabel.text = title
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: 30)
    }
    
    func setupOkButton(with title: String) {
        self.okButton.setTitle(title, for: .normal)
    }
    
    func dismissDeleteAccountFlow() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
}
