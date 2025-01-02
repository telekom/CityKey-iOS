//
//  SCDataPrivacySettingsPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 30/06/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCDataPrivacySettingsPresenter {
    
    weak private var display: SCDataPrivacySettingsDisplay?
    private var appContentSharedWorker: SCAppContentSharedWorking
    private var injector : SCLegalInfoInjecting
    private let shouldPushDataPrivacyController : Bool
    private let preventSwipeToDismiss : Bool
    private let isFirstRunSettings: Bool
    var completionHandler: (() -> Void)?
    
    init(appContentSharedWorker: SCAppContentSharedWorking , injector : SCLegalInfoInjecting , shouldPushDataPrivacyController : Bool, preventSwipeToDismiss : Bool, isFirstRunSettings: Bool) {
        
        self.appContentSharedWorker = appContentSharedWorker
        self.injector = injector
        self.shouldPushDataPrivacyController = shouldPushDataPrivacyController
        self.preventSwipeToDismiss = preventSwipeToDismiss
        self.isFirstRunSettings = isFirstRunSettings
    }
}

extension SCDataPrivacySettingsPresenter : SCDataPrivacySettingsPresenting {
        
    func setDisplay(_ display: SCDataPrivacySettingsDisplay) {
        self.display = display
    }
    
    func backButtonPressed() {
                
    }
    
    func dataPrivacyLinkPressed() {
        
//        let viewController = injector.getDataPrivacyController(presentationType: .dataPrivacy, insideNavCtrl: false)
        
        if shouldPushDataPrivacyController {
            let viewController = injector.getDataPrivacyController(preventSwipeToDismiss: true, shouldPushSettingsController: false)
            display?.push(viewController)
        } else {
            
            display?.popViewController()
        }
    }
    
    func acceptSelectedPressed(adjustSwitchStatus: Bool) {
        self.appContentSharedWorker.privacyOptOutMoEngage = true
        self.appContentSharedWorker.privacyOptOutAdjust = !adjustSwitchStatus
        self.appContentSharedWorker.trackingPermissionFinished = true
        if isFirstRunSettings {
            display?.dismiss(completionHandler: completionHandler)
        } else {
            display?.popViewController()
        }
    }
    
    func acceptAllPressed() {
        self.appContentSharedWorker.privacyOptOutMoEngage = true
        self.appContentSharedWorker.privacyOptOutAdjust = false
        self.appContentSharedWorker.trackingPermissionFinished = true
        if isFirstRunSettings {
            display?.dismiss(completionHandler: completionHandler)
        } else {
            display?.popViewController()
        }
    }
    
    func viewDidLoad() {
        
        if preventSwipeToDismiss {
            
            display?.preventSwipeToDismiss()
        }
        
        display?.setupUI(navigationTitle: LocalizationKeys.DataPrivacySettings.dialogDpnSettingsTitle.localized(),
                         title: LocalizationKeys.DataPrivacySettings.dialogDpnSettingsHeadline.localized(),
                         description: LocalizationKeys.DataPrivacySettings.dialogDpnSettingsDescription.localized(),
                         moengageTitle: LocalizationKeys.DataPrivacySettings.dialogDpnSettingsRequiredHeadline.localized(),
                         moengageDescription: LocalizationKeys.DataPrivacySettings.dialogDpnSettingsRequiredDescription.localized(),
                         adjustTitle: LocalizationKeys.DataPrivacySettings.dialogDpnSettingsOptionalHeadline.localized(),
                         adjustDescription: LocalizationKeys.DataPrivacySettings.dialogDpnSettingsOptionalDescription.localized(),
                         adjustEnabled: !appContentSharedWorker.privacyOptOutAdjust)
    }
}
