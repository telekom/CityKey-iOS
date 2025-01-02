//
//  SCPWDRestoreUnlockFinishedPresenter.swift
//  SmartCity
//
//  Created by Michael on 19.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCPWDRestoreUnlockFinishedDisplaying: AnyObject, SCDisplaying  {
    
    func displayResendFinished()
    func hideResentButton(hide: Bool)
    func setupUI(with email: String)

}

protocol SCPWDRestoreUnlockFinishedPresenting: SCPresenting {
    func setDisplay(_ display: SCPWDRestoreUnlockFinishedDisplaying)
    
    func resendWasPressed()
    
}

class SCPWDRestoreUnlockFinishedPresenter {
    weak private var display : SCPWDRestoreUnlockFinishedDisplaying?
    
    private let restoreUnlockFinishedWorker: SCPWDRestoreUnlockFinishedWorking
    private let injector: SCRegistrationInjecting
    private let email: String
    
    init(email: String, restoreUnlockFinishedWorker: SCPWDRestoreUnlockFinishedWorker, injector: SCRegistrationInjecting) {
        
        self.email = email
        self.restoreUnlockFinishedWorker = restoreUnlockFinishedWorker
        self.injector = injector
    }
    
    deinit {
        
    }
    
    private func setupUI() {
        self.display?.setupUI(with: self.email)
        self.display?.hideResentButton(hide: true)
    }
    
    func resendEMail(_ email : String, pwd : String) {
        self.restoreUnlockFinishedWorker.recoverPassword(email, pwd: pwd, completion: { (error) in
            
            guard error == nil else {
                self.display?.showErrorDialog(error!, retryHandler: {self.resendEMail(email, pwd: pwd)})
                return
            }
            
            self.display?.displayResendFinished()
        })
        
    }

}

extension SCPWDRestoreUnlockFinishedPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.setupUI()
    }
    
    func viewWillAppear() {
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCPWDRestoreUnlockFinishedPresenter: SCPWDRestoreUnlockFinishedPresenting {
    func setDisplay(_ display: SCPWDRestoreUnlockFinishedDisplaying) {
        self.display = display
    }
    
    func resendWasPressed() {
        self.resendEMail(self.email, pwd: "")
    }
    
}

