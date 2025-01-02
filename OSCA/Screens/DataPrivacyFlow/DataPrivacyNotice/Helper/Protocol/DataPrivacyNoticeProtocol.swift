//
//  DataPrivacyNoticeProtocol.swift
//  OSCA
//
//  Created by Bhaskar N S on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCDataPrivacyNoticePresenting : AnyObject , SCPresenting {
    func onAcceptClicked()
    func onShowNoticeClicked()
    func setDisplay(_ display : SCDataPrivacyNoticeDisplay)
}

protocol SCDataPrivacyNoticeDisplay : AnyObject , SCDisplaying {
    func setTitle(_ title : String)
    func updateDPNText(_ string : NSAttributedString)
    func push(_ viewController : UIViewController)
    func dismiss()
    func resetAcceptButtonState()
}
