//
//  SCEditPasswordFinishedPresenter.swift
//  SmartCity
//
//  Created by Michael on 21.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCEditPasswordFinishedDisplaying: AnyObject {
    
    func setupUI()
    func dismissView(completion: (() -> Void)?)
    func setFinishButtonState(_ state : SCCustomButtonState)
    func dismiss(completion: (() -> Void)?)

}

protocol SCEditPasswordFinishedPresenting: SCPresenting {
    func setDisplay(_ display: SCEditPasswordFinishedDisplaying)
    
    func finishWasPressed()
    func closeButtonWasPressed()

}

class SCEditPasswordFinishedPresenter {
    weak private var display : SCEditPasswordFinishedDisplaying?
    
    private let editingFinishedWorker: SCEditPasswordFinishedWorking
    private let injector: SCRegistrationInjecting & SCToolsShowing
    private let authProvider: SCLogoutAuthProviding
    private let email: String
    
    init(email: String, editingFinishedWorker: SCEditPasswordFinishedWorker, authProvider: SCLogoutAuthProviding, injector: SCRegistrationInjecting & SCToolsShowing) {
        
        self.email = email
        self.editingFinishedWorker = editingFinishedWorker
        self.injector = injector
        self.authProvider = authProvider
    }
    
    deinit {
        
    }
    
    private func setupUI() {
        self.display?.setupUI()
    }
    
    
}

extension SCEditPasswordFinishedPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.setupUI()
        self.display?.setFinishButtonState(.normal)
    }
    
    func viewWillAppear() {
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditPasswordFinishedPresenter: SCEditPasswordFinishedPresenting {
    func setDisplay(_ display: SCEditPasswordFinishedDisplaying) {
        self.display = display
    }
    
    func finishWasPressed() {
        self.display?.setFinishButtonState(.disabled)
        self.authProvider.logout(logoutReason: .updateSuccessful,completion:  {
            self.display?.dismiss(completion: nil)
        })
    }
    
    func closeButtonWasPressed() {
        self.display?.setFinishButtonState(.disabled)
        self.authProvider.logout(logoutReason: .updateSuccessful,completion:  {
            self.display?.dismiss(completion: nil)
        })
    }
}
