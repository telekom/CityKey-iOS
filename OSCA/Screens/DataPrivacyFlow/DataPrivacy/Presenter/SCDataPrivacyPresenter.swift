//
//  SCDataPrivacyPresenter.swift
//  SmartCity
//
//  Created by Michael on 01.02.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDataPrivacyPresenter {
    
    weak private var display: SCDataPrivacyDisplaying?
    private let injector: SCAdjustTrackingInjection & SCLegalInfoInjecting
    
    private let showCloseBtn : Bool
    private var appContentSharedWorker: SCAppContentSharedWorking

    private let preventSwipeToDismiss : Bool
    private let shouldPushSettingsController : Bool
    
    init(appContentSharedWorker: SCAppContentSharedWorking, injector: SCAdjustTrackingInjection & SCLegalInfoInjecting, showCloseBtn : Bool , preventSwipeToDismiss : Bool , shouldPushSettingsController : Bool) {
        
        self.appContentSharedWorker = appContentSharedWorker
        self.showCloseBtn = showCloseBtn
        self.injector = injector
        self.preventSwipeToDismiss = preventSwipeToDismiss
        self.shouldPushSettingsController = shouldPushSettingsController
    }
        
}

extension SCDataPrivacyPresenter: SCPresenting {
    func viewDidLoad() {
        prepareAndRefreshUI()
    }
    
    func prepareAndRefreshUI() {
        var topText = NSAttributedString(string: "")
        var bottomText = NSAttributedString(string: "")
        
            if let attrStringTop =  self.appContentSharedWorker.getDataSecurity()?.dataUsage.htmlAttributedString {
                let htmlAttrToptring = NSMutableAttributedString(attributedString: attrStringTop)
                htmlAttrToptring.replaceFont(with: UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 22.0), color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
                topText = htmlAttrToptring

            }
            if let attrStringBottom =  self.appContentSharedWorker.getDataSecurity()?.dataUsage2.htmlAttributedString {
                let htmlAttrBottomString = NSMutableAttributedString(attributedString: attrStringBottom)
                htmlAttrBottomString.replaceFont(with: UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 22.0), color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
                bottomText = htmlAttrBottomString
            }
        
        if self.preventSwipeToDismiss {
            self.display?.preventSwipeToDismiss()
        }
        
        self.display?.setupUI(title: LocalizationKeys.SCDataPrivacy.x001WelcomeBtnPrivacyShort.localized().localized(),
                              showCloseBtn: self.showCloseBtn,
                              topText:  self.appContentSharedWorker.getDataSecurity()?.dataUsage ?? "",
                              bottomText: self.appContentSharedWorker.getDataSecurity()?.dataUsage2 ?? "",
                              displayActIndicator : true,
                              appVersion: SCUtilities.currentVersionAndEnv())
    }
}

extension SCDataPrivacyPresenter : SCDataPrivacyPresenting {
    
    func setDisplay(_ display: SCDataPrivacyDisplaying) {
        self.display = display
    }
    
    func closeBtnWasPressed(){
        self.display?.dismiss()
    }

    func saveBtnWasPressed(){
        self.appContentSharedWorker.trackingPermissionFinished = true
        self.display?.dismiss()
    }
    
    func settingsButtonPressed() {
     
        if shouldPushSettingsController {
            let controller = injector.getDataPrivacySettingsController(shouldPushDataPrivacyController: false, preventSwipeToDismiss: self.preventSwipeToDismiss, isFirstRunSettings: false, completionHandler: nil)
            display?.push(controller)
        } else {
            display?.popViewController()
        }
    }
    
}

