//
//  SCEditEMailPresenter.swift
//  SmartCity
//
//  Created by Michael on 21.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCEditEMailDisplaying: AnyObject, SCDisplaying  {
    func setupNavigationBar(title: String)
    func setupUI(email: String)
    
    func eMailFieldContent() -> String?
    
    func showEMailError(message: String)
    func hideEMailError()
    func showEMailOK()
    
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func setSubmitButtonState(_ state : SCCustomButtonState)
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)

}

protocol SCEditEMailPresenting: SCPresenting {
    func setDisplay(_ display: SCEditEMailDisplaying)
    
    func confirmWasPressed()
    func emailFieldDidChange()
    func emailFieldDidEnd()
    func forgotPWDWasPressed()
    func closeButtonWasPressed()

}

class SCEditEMailPresenter: NSObject {
    
    weak private var display : SCEditEMailDisplaying?
    
    private let editEMailWorker: SCEditEMailWorking
    private let authProvider: SCLogoutAuthProviding
    private let injector: SCEditEMailInjecting & SCAdjustTrackingInjection & SCRegistrationInjecting
    private var email: String
    private var finishViewController : UIViewController?
    private weak var presentedVC: UIViewController?

    init(email: String, editEMailWorker: SCEditEMailWorking, authProvider: SCLogoutAuthProviding, injector: SCEditEMailInjecting & SCAdjustTrackingInjection & SCRegistrationInjecting) {
        
        self.editEMailWorker = editEMailWorker
        self.authProvider = authProvider
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
    
    func emailFieldDidChange() {
        self.display?.hideEMailError()
        self.updateValidationState()
//        self.refreshSubmitButtonState()
    }
    
    func emailFieldDidEnd() {
        self.display?.hideEMailError()
        self.updateValidationState()
//        self.refreshSubmitButtonState()
    }
    
    private func updateValidationState(){
        self.display?.setSubmitButtonState(.disabled)
        if  self.display?.eMailFieldContent()?.count ?? 0 > 0 {
            let validationResult = SCInputValidation.isInputValid(self.display?.eMailFieldContent() ?? "", fieldType: .email)
            if !validationResult.isValid {
                self.display?.showEMailError(message: "r_001_registration_error_incorrect_email".localized())
                self.display?.setSubmitButtonState(.disabled)
            }else{
                self.display?.showEMailOK()
                self.display?.setSubmitButtonState(.normal)
            }
        }
        else{
            self.display?.hideEMailError()
        }
    }

    private func refreshSubmitButtonState(){
        self.display?.setSubmitButtonState(.disabled)
        if  self.display?.eMailFieldContent()?.count ?? 0 > 0 {
            self.display?.setSubmitButtonState(.normal)
        }
        else{
            self.display?.hideEMailError()
        }
    }

    func validateInputFields() -> Bool{
        var valid = false
        
        // check if the eMail is valid
        let validationResult = SCInputValidation.isInputValid(self.display?.eMailFieldContent() ?? "", fieldType: .email)
        if !validationResult.isValid {
            self.display?.showEMailError(message: "r_001_registration_error_incorrect_email".localized())
            self.display?.setSubmitButtonState(.disabled)
        }else{
            self.display?.showEMailOK()
            valid = true
        }
        return valid
    }
    
    private func displayErrorDetail(_ detail : SCWorkerErrorDetails){
        
        let error = detail.errorCode ?? ""
        
        switch error {
        default:
            self.display?.showEMailError(message: detail.message)
        }
    }

    private func confirmEMail(isErrorPresent: Bool?, errorMessage: String?){
        let confirmViewController =  self.injector.getRegistrationConfirmEMailVC(registeredEmail:self.display?.eMailFieldContent() ?? "", shouldHideTopImage: true, presentationType: .confirmMailForEditEmail, isError: isErrorPresent, errorMessage: errorMessage, completionOnSuccess: {
            self.presentedVC?.dismiss(animated: true, completion:{})
            self.presentedVC = nil
            self.authProvider.logout(logoutReason: .updateSuccessful,completion:  {
                self.display?.dismiss(completion: nil)
            })
        })
        self.presentedVC = confirmViewController
        self.display?.presentOnTop(viewController: confirmViewController, completion: nil)
        
    }
    
    private func submitNewEMail(_ email: String) {
        
        self.display?.setSubmitButtonState(.progress)
        
        self.editEMailWorker.changeEMail(email, completion: { (error) in
            
            self.display?.setSubmitButtonState(.normal)

            guard error == nil else {
                switch error! {
                case .fetchFailed(let errorDetail):
                    self.display?.setSubmitButtonState(.disabled)
                    self.displayErrorDetail(errorDetail)
                default:
                    self.display?.showErrorDialog(error!, retryHandler: {self.submitNewEMail(email)})
                }
                
                return
            }
            
            self.confirmEMail(isErrorPresent: nil, errorMessage: nil)
        })
        
    }
    
}

extension SCEditEMailPresenter: SCPresenting {
    
    func viewDidLoad() {
        debugPrint("SCEditEMailPresenter->viewDidLoad")
        self.setupUI()
        self.display?.setSubmitButtonState(.disabled)
        
    }
    
    func viewWillAppear() {
        debugPrint("SCEditEMailPresenter->viewWillAppear")
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditEMailPresenter: SCEditEMailPresenting {
    
    func setDisplay(_ display: SCEditEMailDisplaying) {
        self.display = display
    }
    
    func confirmWasPressed(){
        //self.injector.trackEvent(eventName: "ClickChangeEmailConfirmBtn")
        if let email = self.display?.eMailFieldContent(){
            self.submitNewEMail(email)
        }
    }
    
    func forgotPWDWasPressed(){
        //self.injector.trackEvent(eventName: "ClickForgotPasswordBtn")
        let navCtrl = UINavigationController()
        navCtrl.viewControllers = [self.injector.getPWDForgottenViewController(email: self.email, completionOnSuccess: nil)]
        SCUtilities.topViewController().present(navCtrl, animated: true, completion: nil)
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
}
