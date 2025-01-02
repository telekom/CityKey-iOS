//
//  SCEditResidencePresenter.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 15/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCEditResidenceDisplaying: AnyObject, SCDisplaying  {
    func setupNavigationBar(title: String)
    func setupUI(postcode: String)
    
    func postcodeFieldContent() -> String?
    
    
    func showPostcodeMessage(message: String)
    func showPostcodeError(message: String)
    func hidePostcodeError()
    func showPostcodeOK()
    
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func setSubmitButtonState(_ state : SCCustomButtonState)
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
    func dismissView(completion: (() -> Void)?)

}

protocol SCEditResidencePresenting: SCPresenting {
    func setDisplay(_ display: SCEditResidenceDisplaying)
    
    func confirmWasPressed()
    func postcodeFieldDidChange()
    func postcodeFieldDidEnd()
    func closeButtonWasPressed()

}

class SCEditResidencePresenter{
    
    weak private var display : SCEditResidenceDisplaying?
    
    private let editResidenceWorker: SCEditResidenceWorking
    private let injector: SCAdjustTrackingInjection & SCToolsShowing
    private var postcode: String
    private var profile: SCModelProfile?
    private var finishViewController : UIViewController?
    private weak var presentedVC: UIViewController?

    init(postcode: String, profile: SCModelProfile, editResidenceWorker: SCEditResidenceWorking, injector: SCAdjustTrackingInjection & SCToolsShowing) {
        
        self.editResidenceWorker = editResidenceWorker
        self.injector = injector
        self.postcode = postcode
        self.profile = profile
                
        self.setupNotifications()
    }
    
    deinit {
    }
    
    private func setupUI() {
        self.display?.setupNavigationBar(title: "p_003_profile_new_postcode_title".localized())
        self.profile = SCUserDefaultsHelper.getProfile()
        self.display?.setupUI(postcode: self.profile?.postalCode ?? "")
    }
    
    private func setupNotifications() {
        
    }
    
    func postcodeFieldDidChange() {
        self.display?.hidePostcodeError()
//        self.updateValidationState()
        self.refreshSubmitButtonState()
    }
    
    func postcodeFieldDidEnd() {
        self.display?.hidePostcodeError()
//        self.updateValidationState()
        self.refreshSubmitButtonState()
    }
    
    private func updateValidationState(){
        let validationResult = SCInputValidation.isInputValid(self.display?.postcodeFieldContent() ?? "", fieldType: .postalCode)
        if !validationResult.isValid {
            self.display?.showPostcodeError(message: "r_001_registration_error_incorrect_postcode".localized())
        }else{
            self.display?.showPostcodeOK()
        }
    }

    private func refreshSubmitButtonState(){
        self.display?.setSubmitButtonState(.disabled)
        if  self.display?.postcodeFieldContent()?.count ?? 0 > 0 {
            self.display?.setSubmitButtonState(.normal)
        }
        else{
            self.display?.hidePostcodeError()
        }
    }

    func validateInputFields() -> Bool{
        var valid = false
        
        // check if the postcode is valid
//        if self.display?.postcodeFieldContent() == self.postcode {
        let validationResult = SCInputValidation.isInputValid(self.display?.postcodeFieldContent() ?? "", fieldType: .postalCode)
        if !validationResult.isValid {
            self.display?.showPostcodeError(message: "r_001_registration_error_incorrect_postcode".localized())
            self.display?.setSubmitButtonState(.disabled)
        }else {
            valid = true
        }
        return valid
    }
    
    private func displayErrorDetail(_ detail : SCWorkerErrorDetails){
                
        let error = detail.errorCode ?? ""
        switch error {
        case "postalCode.validation.error":
            self.display?.showPostcodeError(message: detail.message)
        case "user.postal.code.invalid":
            self.display?.showPostcodeError(message: detail.message)
        default:
            self.display?.showErrorDialog(with: detail.message, retryHandler : nil, showCancelButton: false, additionalButtonTitle: nil, additionButtonHandler: nil)
            break
        }
        
    }
    
    private func submitNewPostcode(_ postcode: String) {
        
        if  validateInputFields() {
            
            self.display?.setSubmitButtonState(.progress)
            
            self.editResidenceWorker.changeResidence("", postcode: postcode, completion: { (error) in
                
                self.display?.setSubmitButtonState(.normal)

                guard error == nil else {
                    switch error! {
                    case .fetchFailed(let errorDetail):
                        self.display?.setSubmitButtonState(.disabled)
                        self.displayErrorDetail(errorDetail)
                    default:
                        self.display?.showErrorDialog(error!, retryHandler: {self.submitNewPostcode(postcode)})
                    }
                    
                    return
                }
                
                SCUtilities.delay(withTime: 0.0, callback: {
                    self.display?.dismissView(completion: nil)
                })
            })
            
        } else {
            self.display?.setSubmitButtonState(.disabled)
        }
        
    }
    
    private func validatePostalCode(_ postcode: String) {
        
        self.display?.setSubmitButtonState(.progress)
        
        self.editResidenceWorker.validatePostalCode(postcode, completion: { (postalCodeInfo, error)  in
            
            self.display?.setSubmitButtonState(.normal)

            guard error == nil else {
                switch error! {
                case .fetchFailed(let errorDetail):
                    self.display?.setSubmitButtonState(.disabled)
                    self.displayErrorDetail(errorDetail)
                default:
                    self.display?.showErrorDialog(error!, retryHandler: {self.validatePostalCode(postcode)})
                }
                
                return
            }
            
            self.display?.showPostcodeMessage(message: postalCodeInfo?.postalCodeMessage ?? "")
            self.updatePersonalData(postcode, validatePostcodeData: postalCodeInfo!)
            self.submitNewPostcode(postcode)
        })
        
    }
    
    private func updatePersonalData(_ postcode: String, validatePostcodeData: SCHttpResponseValidatePostcode){
        self.profile?.postalCode = postcode
        self.profile?.cityName = validatePostcodeData.cityName
        self.profile?.homeCityId = validatePostcodeData.homeCityId
        SCUserDefaultsHelper.setProfile(profile: self.profile!)

    }
    
}

extension SCEditResidencePresenter: SCPresenting {
    
    func viewDidLoad() {
        debugPrint("SCEditResidencePresenter->viewDidLoad")
        self.setupUI()
        self.display?.setSubmitButtonState(.disabled)
        
    }
    
    func viewWillAppear() {
        debugPrint("SCEditResidencePresenter->viewWillAppear")
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditResidencePresenter: SCEditResidencePresenting {
    
    func setDisplay(_ display: SCEditResidenceDisplaying) {
        self.display = display
    }
    
    func confirmWasPressed(){
        //self.injector.trackEvent(eventName: "ClickChangeEmailConfirmBtn")
        if  validateInputFields() {
            if let postcode = self.display?.postcodeFieldContent(){
                self.validatePostalCode(postcode)
            }
        } else {
            self.display?.setSubmitButtonState(.disabled)
        }
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
}
