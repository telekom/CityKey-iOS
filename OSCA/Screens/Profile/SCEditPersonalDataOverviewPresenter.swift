//
//  SCEditPersonalDataOverviewPresenter.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 15/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import TTGSnackbar

protocol SCEditPersonalDataOverviewDisplaying: AnyObject, SCDisplaying {
    func setupNavigationBar(title: String)
    func setupUI(postcode: String, profile: SCModelProfile)
    func push(viewController: UIViewController)
    func dismiss(completion: (() -> Void)?)

}

protocol SCEditPersonalDataOverviewPresenting: SCPresenting {
    func setDisplay(_ display: SCEditPersonalDataOverviewDisplaying)
    
    func editDateOfBirthWasPressed()
    func editResidenceWasPressed()
    func closeButtonWasPressed()
    func displayToastWith(message: String)

}

class SCEditPersonalDataOverviewPresenter{
    
    weak private var display : SCEditPersonalDataOverviewDisplaying?
    
    private let personalDataEditOverviewWorker: SCEditPersonalDataOverviewWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    private let authProvider: SCLogoutAuthProviding
    private let injector: SCEditProfileInjecting //SCEditPersonalDataInjecting
    private var postcode: String
    private var profile: SCModelProfile?
    private var finishViewController : UIViewController?
    
    init(postcode: String, profile: SCModelProfile, personalDataEditOverviewWorker: SCEditPersonalDataOverviewWorking, userContentSharedWorker: SCUserContentSharedWorking, authProvider: SCLogoutAuthProviding, injector: SCEditProfileInjecting) {
        
        self.personalDataEditOverviewWorker = personalDataEditOverviewWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.authProvider = authProvider
        self.injector = injector
        self.postcode = postcode
        self.profile = profile
        
        self.setupNotifications()
    }
    
    deinit {
    }

    private func setupUI() {
        self.display?.setupNavigationBar(title: "p_001_profile_label_personal_data".localized())
        self.display?.setupUI(postcode: self.postcode, profile: self.profile!)
    }
    
    private func setupNotifications() {
        
    }
    
    private func updateContent(){
        self.profile = SCUserDefaultsHelper.getProfile()
        self.display?.setupUI(postcode: self.profile?.postalCode ?? "", profile: self.profile!)
    }
    
    private func triggerUserDataUpdate() {
        debugPrint("SCProfilePresenter->triggerUserDataUpdate")
        
        if authProvider.isUserLoggedIn(){
            self.userContentSharedWorker.triggerUserDataUpdate { (error) in
                                
                if error != nil {
                    
                    self.display?.showErrorDialog(error!, retryHandler : { self.triggerUserDataUpdate() }, additionalButtonTitle: "p_001_profile_btn_logout".localized(), additionButtonHandler : nil)
                }
            }
       }
    }
}

extension SCEditPersonalDataOverviewPresenter: SCPresenting {
    
    func viewDidLoad() {
        debugPrint("SCEditPersonalDataOverviewPresenter->viewDidLoad")
        self.setupUI()
    }
    
    func viewWillAppear() {
        debugPrint("SCEditPersonalDataOverviewPresenter->viewWillAppear")
        self.updateContent()
        self.triggerUserDataUpdate()
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditPersonalDataOverviewPresenter: SCEditPersonalDataOverviewPresenting {

    func setDisplay(_ display: SCEditPersonalDataOverviewDisplaying) {
        self.display = display
    }
    
    func editDateOfBirthWasPressed(){
        
        self.display?.push(viewController: self.injector.getProfileEditDateOfBirthViewController(in: .editProfile,
                                                                                                 completionHandler: nil) )
        //self.displayToastWith(message: "p_001_profile_residence_snackbar_message".localized())
    }
    
    func editResidenceWasPressed(){
        self.display?.push(viewController: self.injector.getProfileEditResidenceViewController(postcode: postcode))
    }

    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
    func displayToastWith(message: String) {
        let snackbar = TTGSnackbar(
            message: message,
            duration: .middle
        )

        snackbar.setCustomStyle()
        snackbar.show()
    }
}
