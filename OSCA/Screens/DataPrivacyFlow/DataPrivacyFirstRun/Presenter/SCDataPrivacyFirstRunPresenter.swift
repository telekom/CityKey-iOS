//
//  SCDataPrivacyFirstRunPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 30/06/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCDataPrivacyFirstRunPresenter {
    
    weak private var display: SCDataPrivacyFirstRunDisplay?
    private var appContentSharedWorker: SCAppContentSharedWorking
    private var injector : SCLegalInfoInjecting
    private let preventSwipeToDismiss: Bool
    var completionHandler: (() -> Void)?
    
    init(appContentSharedWorker: SCAppContentSharedWorking , injector : SCLegalInfoInjecting , preventSwipeToDismiss : Bool) {
        
        self.appContentSharedWorker = appContentSharedWorker
        self.injector = injector
        self.preventSwipeToDismiss = preventSwipeToDismiss
    }

    
}

extension SCDataPrivacyFirstRunPresenter : SCDataPrivacyFirstRunPresenting {
  
    func setDisplay(_ display: SCDataPrivacyFirstRunDisplay) {
        self.display = display
    }
    
    func changeSettingsPressed() {
        
        let viewController = self.injector.getDataPrivacySettingsController(shouldPushDataPrivacyController: true, preventSwipeToDismiss: true,
                                                                            isFirstRunSettings: true, completionHandler: completionHandler)
        display?.navigateTo(viewController)
        
    }
    
    func acceptAllPressed() {
        
        self.appContentSharedWorker.privacyOptOutMoEngage = true
        self.appContentSharedWorker.privacyOptOutAdjust = false
        self.appContentSharedWorker.trackingPermissionFinished = true
        display?.dismiss(completion: completionHandler)
        
    }
    
    func acceptSelectedLinkPressed() {
      
        self.appContentSharedWorker.privacyOptOutMoEngage = true
        self.appContentSharedWorker.privacyOptOutAdjust = true
        self.appContentSharedWorker.trackingPermissionFinished = true
        display?.dismiss(completion: completionHandler)
    }
    
    func dataPrivacyNoticeLinkPressed() {
        
        let viewController = self.injector.getDataPrivacyController(preventSwipeToDismiss: true, shouldPushSettingsController: true)
        display?.navigateTo(viewController)
    }
    
    func viewDidLoad() {
        
        if preventSwipeToDismiss {
            display?.preventSwipeToDismiss()
        }
     
        display?.setupUI(navigationTitle: LocalizationKeys.DataPrivacySettings.dialogDpnSettingsTitle.localized(),
                         description: LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuTextFormat.localized())
    }
}
