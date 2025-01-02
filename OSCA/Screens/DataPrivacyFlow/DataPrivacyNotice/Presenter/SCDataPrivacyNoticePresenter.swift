//
//  SCDataPrivacyNoticePresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 21/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCDataPrivacyNoticePresenter {
    
    weak private var display: SCDataPrivacyNoticeDisplay?
    private var appContentSharedWorker: SCAppContentSharedWorking
    private var injector : SCLegalInfoInjecting
    
    init(appContentSharedWorker: SCAppContentSharedWorking , injector : SCLegalInfoInjecting ) {
        
        self.appContentSharedWorker = appContentSharedWorker
        self.injector = injector
    }

    private func getDPNAttributedText() -> NSAttributedString? {
        
        if let attrString =  appContentSharedWorker.getDataSecurity()?.noticeText.htmlAttributedString?.trimmedAttributedString(set: .whitespacesAndNewlines) {
            
            let htmlAttributedString = NSMutableAttributedString(attributedString: attrString)
            
            htmlAttributedString.replaceFont(with: UIFont.systemFont(ofSize: (UIScreen.main.bounds.size.width) == 320 ? 14.0 : 16.0, weight: UIFont.Weight.medium), color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
            
            return htmlAttributedString
        }
        return nil

    }
}

extension SCDataPrivacyNoticePresenter : SCDataPrivacyNoticePresenting {
        
    func viewDidLoad() {
        
        display?.updateDPNText(self.getDPNAttributedText() ?? NSAttributedString(string: ""))
        display?.setTitle(LocalizationKeys.SCDataPrivacyNotice.dialogDpnUpdatedTitle.localized())
    }

    func onAcceptClicked() {
        self.appContentSharedWorker.acceptDataPrivacyNoticeChange { [weak self] (error, result) in
            guard let strongSelf = self else {
                return
            }
            if let error = error  {
                
                strongSelf.display?.resetAcceptButtonState()
                strongSelf.display?.showErrorDialog(error, retryHandler: {
                    self?.onAcceptClicked()
                },
                                                    showCancelButton: true,
                                                    additionalButtonTitle: nil,
                                                    additionButtonHandler: nil)
            } else if 1 == ( result ?? -1 ) {
                strongSelf.display?.dismiss()
            } else {
                
                strongSelf.display?.resetAcceptButtonState()
                strongSelf.display?.showErrorDialog(with: LocalizationKeys.SCDataPrivacyNotice.dialogTechnicalErrorMessage.localized(),
                                               retryHandler: nil,
                                                    showCancelButton: true,
                                                    additionalButtonTitle: nil, additionButtonHandler: nil )
            }
        }
    }
    
    func onShowNoticeClicked() {
        let viewController = injector.getDataPrivacyController(preventSwipeToDismiss: true, shouldPushSettingsController: true)
        display?.push(viewController)
    }
    
    func setDisplay(_ display : SCDataPrivacyNoticeDisplay) {
        self.display = display
    }
}
