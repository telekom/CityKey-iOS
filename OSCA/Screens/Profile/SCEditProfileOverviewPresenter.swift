//
//  SCEditProfileOverviewPresenter.swift
//  SmartCity
//
//  Created by Michael on 21.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCEditProfileOverviewDisplaying: AnyObject {
    func setupNavigationBar(title: String)
    func setupUI(email: String)
    func push(viewController: UIViewController)
    func dismiss(completion: (() -> Void)?)

}

protocol SCEditProfileOverviewPresenting: SCPresenting {
    func setDisplay(_ display: SCEditProfileOverviewDisplaying)
    
    func editPWDWasPressed()
    func editEMailWasPressed()
    func deleteAccountWasPressed()
    func closeButtonWasPressed()

}

enum DateOfBirth: String {
    case editProfile
    case registration
}

class SCEditProfileOverviewPresenter: NSObject {
    
    weak private var display : SCEditProfileOverviewDisplaying?
    
    private let profileEditOverviewWorker: SCEditProfileOverviewWorking
    private let injector: SCEditProfileInjecting
    private var email: String
    private var finishViewController : UIViewController?
    
    init(email: String, profileEditOverviewWorker: SCEditProfileOverviewWorking, injector: SCEditProfileInjecting) {
        
        self.profileEditOverviewWorker = profileEditOverviewWorker
        self.injector = injector
        self.email = email
        
        super.init()
        
        self.setupNotifications()
    }
    
    deinit {
    }

    private func setupUI() {
        self.display?.setupNavigationBar(title: "p_001_profile_label_account_settings".localized())
        self.display?.setupUI(email: self.email)
    }
    
    private func setupNotifications() {
        
    }
    
    
}

extension SCEditProfileOverviewPresenter: SCPresenting {
    
    func viewDidLoad() {
        debugPrint("SCEditProfileOverviewPresenter->viewDidLoad")
        self.setupUI()
    }
    
    func viewWillAppear() {
        debugPrint("SCEditProfileOverviewPresenter->viewWillAppear")
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditProfileOverviewPresenter: SCEditProfileOverviewPresenting {
    func deleteAccountWasPressed() {
        self.display?.push(viewController: self.injector.getDeleteAccountViewController())
    }
    
    
    func setDisplay(_ display: SCEditProfileOverviewDisplaying) {
        self.display = display
    }
    
    func editPWDWasPressed(){
        self.display?.push(viewController: self.injector.getProfileEditPasswordViewController(email: email))
        
    }
    
    func editEMailWasPressed(){
        self.display?.push(viewController: self.injector.getProfileEditEMailViewController(email: email))
    }

    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
}
