//
//  SCDataPrivacyFirstRunProtocol.swift
//  OSCA
//
//  Created by Bhaskar N S on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
protocol SCDataPrivacyFirstRunDisplay: AnyObject, SCDisplaying {
    
    func setupUI(navigationTitle: String,
                 description: String)
    func preventSwipeToDismiss()
    func dismiss()
    func navigateTo(_ controller : UIViewController)
    func dismiss(completion: (() -> Void)?)
}

protocol SCDataPrivacyFirstRunPresenting: SCPresenting {
    
    func setDisplay(_ display: SCDataPrivacyFirstRunDisplay)
    func changeSettingsPressed()
    func acceptAllPressed()
    func acceptSelectedLinkPressed()
    func dataPrivacyNoticeLinkPressed()
    var completionHandler: (() -> Void)? { get set }
}


