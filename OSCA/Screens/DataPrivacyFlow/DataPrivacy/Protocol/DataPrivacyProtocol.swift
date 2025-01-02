//
//  DataPrivacyProtocol.swift
//  OSCA
//
//  Created by Bhaskar N S on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCDataPrivacyDisplaying: AnyObject, SCDisplaying {
    func setupUI(title: String,
                 showCloseBtn : Bool,
                 topText: String,
                 bottomText: String,
                 displayActIndicator: Bool,
                 appVersion: String?)
    
    func preventSwipeToDismiss()
    func dismiss()
    func push(_ viewController : UIViewController)
    func popViewController()
}

protocol SCDataPrivacyPresenting: SCPresenting {
    func setDisplay(_ display: SCDataPrivacyDisplaying)
    
    func closeBtnWasPressed()
    func settingsButtonPressed()
    func prepareAndRefreshUI()
}
