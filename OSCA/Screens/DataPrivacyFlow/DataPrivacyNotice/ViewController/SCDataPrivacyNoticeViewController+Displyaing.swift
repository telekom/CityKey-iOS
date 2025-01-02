//
//  SCDataPrivacyNoticeViewController+Displyaing.swift
//  OSCA
//
//  Created by Bhaskar N S on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCDataPrivacyNoticeViewController : SCDataPrivacyNoticeDisplay {
    
    func setTitle(_ title: String) {
        self.navigationItem.title = title
    }
    
    func updateDPNText(_ string: NSAttributedString) {
        textView.attributedText = string
    }
    
    func push(_ viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func dismiss() {
        self.navigationController?.dismiss(animated: true, completion: nil )
    }
    
    func resetAcceptButtonState() {
        okButton.btnState = .normal
    }
}
