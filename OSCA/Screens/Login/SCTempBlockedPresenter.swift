//
//  SCTempBlockedPresenter.swift
//  SmartCity
//
//  Created by Michael on 19.02.20.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCTempBlockedDisplaying: AnyObject, SCDisplaying {
    
    func setupNavigationBar(title: String)
    func setupUI()
    func push(viewController: UIViewController)
    func dismissView(completion: (() -> Void)?)
}

protocol SCTempBlockedPresenting: SCPresenting {
    func setDisplay(_ display: SCTempBlockedDisplaying)
    
    func resetWasPressed()
}

class SCTempBlockedPresenter {
    weak private var display : SCTempBlockedDisplaying?
    
    private let injector: SCLoginInjecting
    private let email: String
    
    init(email: String, injector: SCLoginInjecting) {
        
        self.email = email
        self.injector = injector
    }
    
    deinit {
        
    }
    
    private func setupUI() {
        self.display?.setupNavigationBar(title: "l_002_login_locked_account_title".localized())
        self.display?.setupUI()
    }
    
}

extension SCTempBlockedPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.setupUI()
    }
    
    
    func viewWillAppear() {
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCTempBlockedPresenter: SCTempBlockedPresenting {
    
    func setDisplay(_ display: SCTempBlockedDisplaying) {
        self.display = display
    }
    
    func resetWasPressed() {
        
        //self.display?.push(viewController:self.injector.getForgottenViewController(email: self.email))

    }

    func finishWasPressed(){
        
        self.display?.dismissView(completion: {
        })
        
    }

}
