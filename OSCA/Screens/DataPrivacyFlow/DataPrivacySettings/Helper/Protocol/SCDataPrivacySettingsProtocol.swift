//
//  SCDataPrivacySettingsProtocol.swift
//  OSCA
//
//  Created by Bhaskar N S on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCDataPrivacySettingsDisplay: AnyObject, SCDisplaying {
    
    func setupUI(navigationTitle: String,
                 title: String,
                 description: String,
                 moengageTitle: String,
                 moengageDescription: String,
                 adjustTitle: String,
                 adjustDescription: String,
                 adjustEnabled: Bool)
    
    func preventSwipeToDismiss()
    func dismiss()
    func push(_ controller : UIViewController)
    func popViewController()
    func dismiss(completionHandler: (() -> Void)?)
}

protocol SCDataPrivacySettingsPresenting: SCPresenting {
    
    func setDisplay(_ display: SCDataPrivacySettingsDisplay)
    func backButtonPressed()
    func dataPrivacyLinkPressed()
    func acceptAllPressed()
    func acceptSelectedPressed(adjustSwitchStatus : Bool)
    var completionHandler: (() -> Void)? { get set }
}
