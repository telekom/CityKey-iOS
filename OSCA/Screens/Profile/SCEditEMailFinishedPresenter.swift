//
//  SCEditEMailFinishedPresenter.swift
//  SmartCity
//
//  Created by Michael on 21.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCEditEMailFinishedDisplaying: AnyObject, SCDisplaying {
    
    func setupNavigationBar(title: String)
    func setupUI(email : String)
    func dismissView(completion: (() -> Void)?)
    func popViewController()
    func displayResendFinished()
    func dismiss(completion: (() -> Void)?)

}

protocol SCEditEMailFinishedPresenting: SCPresenting {
    func setDisplay(_ display: SCEditEMailFinishedDisplaying)
    
    func finishWasPressed()
    func retryWasPresssed()
    func closeButtonWasPressed()

}

class SCEditEMailFinishedPresenter {
    weak private var display : SCEditEMailFinishedDisplaying?
    
    private let injector: SCRegistrationInjecting & SCToolsShowing
    private let email: String
    
    init(email: String, injector: SCRegistrationInjecting & SCToolsShowing) {
        
        self.email = email
        self.injector = injector
    }
    
    deinit {
        
    }
    
    private func setupUI() {
        self.display?.setupNavigationBar(title: "p_004_profile_email_changed_title".localized())
        self.display?.setupUI(email: self.email)
    }
    
}

extension SCEditEMailFinishedPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.setupUI()
    }
    
    func viewWillAppear() {
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditEMailFinishedPresenter: SCEditEMailFinishedPresenting {
    func setDisplay(_ display: SCEditEMailFinishedDisplaying) {
        self.display = display
    }
    
    func finishWasPressed(){
        SCUtilities.delay(withTime: 0.0, callback: {
            self.display?.dismissView(completion: {
                self.injector.showProfile()
            })
        })
    }

    func retryWasPresssed() {
        
        self.display?.popViewController()
        
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
}
