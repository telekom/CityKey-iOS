//
//  SCDeleteAccountSuccessPresenter.swift
//  SmartCity
//
//  Created by Alexander Lichius on 15.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

class SCDeleteAccountSuccessPresenter {
    var display: SCDeleteAccountSuccessDisplaying?
    var injector: SCDeleteAccountInjecting
    var authProvider: SCLogoutAuthProviding
    
    init(injector: SCDeleteAccountInjecting, authProvider: SCLogoutAuthProviding) {
        self.injector = injector
        self.authProvider = authProvider
    }
    
    func setupUI() {
        self.display?.setupNavigationBar(with: "d_003_delete_account_confirmation_title".localized())
        self.display?.setupOkButton(with: "dialog_button_ok".localized())
        self.display?.setupTitleLabel(text: "d_003_delete_account_confirmation_info1".localized())
        self.display?.setupSubtitleLabel(text: "d_003_delete_account_confirmation_info3".localized())
        self.display?.setupDescriptionLabel(text: "d_003_delete_account_confirmation_info2".localized())

    }
    
}

extension SCDeleteAccountSuccessPresenter: SCDeleteAccountSuccessPresenting {
    func setDisplay(_ display: SCDeleteAccountSuccessDisplaying) {
        self.display = display
    }
    
    func okButtonTapped() {
        self.authProvider.logout(logoutReason: .accountDeleted,completion: {
//            self.display?.dismissDeleteAccountFlow()
//            SCDataUIEvents.postNotification(for: NSNotification.Name.userDidSignOut)
        })
    }
    
    func closeButtonWasPressed() {
        self.authProvider.logout(logoutReason: .accountDeleted,completion: {
            self.display?.dismiss(completion: nil)
//            SCDataUIEvents.postNotification(for: NSNotification.Name.userDidSignOut)
        })
    }
}

extension SCDeleteAccountSuccessPresenter: SCPresenting {
    func viewDidLoad() {
        self.setupUI()
    }
}
