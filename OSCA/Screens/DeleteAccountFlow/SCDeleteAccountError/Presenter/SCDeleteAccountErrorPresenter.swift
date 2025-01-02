//
//  SCDeleteAccountErrorPresenter.swift
//  SmartCity
//
//  Created by Alexander Lichius on 15.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

class SCDeleteAccountErrorPresenter {
    var display: SCDeleteAccountErrorDisplaying?
    func setupUI() {
        self.display?.setupTitleLabel(with: "d_004_delete_account_error_info1".localized())
        self.display?.setupSubtitleLabel(with: "d_004_delete_account_error_info2".localized())
        self.display?.setupOkButton(with: "dialog_button_ok".localized())
    }
}

extension SCDeleteAccountErrorPresenter: SCDeleteAccountErrorPresenting {
    func setDisplay(_ display: SCDeleteAccountErrorDisplaying) {
        self.display = display
    }
    
    func okButtonTapped() {
        self.display?.dismissDeleteAccountFlow()
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
}
