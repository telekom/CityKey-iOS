//
//  SCEditDateOfBirthPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 29/04/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol SCEditDateOfBirthDisplaying : AnyObject , SCDisplaying {
    
    func setupNavigationBar(title: String)
    func setupUI(dob: String?)
    
    func dobFieldContent() -> String?
    
    
    func showDobMessage(message: String)
    func showDobError(message: String)
    func hideDobError()
    func showDobOK()
    
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func setSubmitButtonState(_ state : SCCustomButtonState)
    func setClearDOBButtonState(_ state : SCCustomButtonState)
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
    func dismissView(completion: (() -> Void)?)
    func popViewController()
}

protocol SCEditDateOfBirthPresenting: SCPresenting {
    func setDisplay(_ display: SCEditDateOfBirthDisplaying)
    
    func confirmWasPressed()
    func dobFieldDidChange()
    func dobFieldDidEnd()
    func closeButtonWasPressed()
    func clearDOBButtonWasPressed()
}

class SCEditDateOfBirthPresenter {
    
    weak private var display : SCEditDateOfBirthDisplaying?
    
    private let editDateOfBirthWorker: SCEditDateOfBirthWorking
    private let injector: SCAdjustTrackingInjection & SCToolsShowing
    private var profile: SCModelProfile?
    private var finishViewController : UIViewController?
    private weak var presentedVC: UIViewController?
    private var flow: DateOfBirth?
    private var completionHandler: ((String?) -> Void)?

    init(profile: SCModelProfile?, editDateOfBirthWorker: SCEditDateOfBirthWorking, injector: SCAdjustTrackingInjection & SCToolsShowing, flow: DateOfBirth? = .editProfile, completionHandler: ((String?) -> Void)?) {
        
        self.profile = profile
        self.editDateOfBirthWorker = editDateOfBirthWorker
        self.injector = injector
        self.flow = flow
        self.completionHandler = completionHandler
    }
    
    deinit {
    }
    
    private func setupUI() {
        
        if let date = self.profile?.birthdate {
            let dateString = birthdayStringFromDate(birthdate: date)
            self.display?.setupUI(dob : dateString)
            self.display?.setupNavigationBar(title: "p_003_change_dob_title".localized())
        } else {
            self.display?.setupUI(dob : nil)
            self.display?.setupNavigationBar(title: "p_003_add_date_of_birth_title".localized())
        }
    }
    
    func dobFieldDidChange() {
        self.display?.hideDobError()
        self.updateValidationState()
        self.refreshSubmitButtonState()
    }
    
    func dobFieldDidEnd() {
        self.display?.hideDobError()
        self.updateValidationState()
        self.refreshSubmitButtonState()
    }
    
    private func updateValidationState(){
        let validationResult = SCInputValidation.isInputValid(self.display?.dobFieldContent() ?? "", fieldType: .birthdate)
        if !validationResult.isValid {
            self.display?.showDobError(message: "error".localized())
        }else{
            self.display?.showDobOK()
        }
    }

    private func refreshSubmitButtonState(){
        self.display?.setSubmitButtonState(.disabled)
        if  self.display?.dobFieldContent()?.count ?? 0 > 0 {
            
            self.display?.setSubmitButtonState(.normal)
        } else {
            
            self.display?.hideDobError()
        }
    }

    func validateInputFields() -> Bool{
        var valid = false
        
        let validationResult = SCInputValidation.isInputValid(self.display?.dobFieldContent() ?? "", fieldType: .birthdate)
        
        if !validationResult.isValid {
            self.display?.showDobError(message: "error".localized())
            self.display?.setSubmitButtonState(.disabled)
        }else {
            valid = true
        }
        return valid
    }
    
    private func displayErrorDetail(_ detail : SCWorkerErrorDetails){
                
        let error = detail.errorCode ?? ""
        switch error {
        case "dateOfBirthvalidation.error":
            self.display?.showDobError(message: detail.message)
        case "user.dob.not.valid":
            self.display?.showDobError(message: detail.message)
        default:
            self.display?.showErrorDialog(with: detail.message, retryHandler : nil, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
            break
        }
        
    }
    
    private func submitNewDateOfBirth(_ dob: String) {
        
        if  validateInputFields() {
            
            self.display?.setSubmitButtonState(.progress)
            
            self.editDateOfBirthWorker.updateDateOfBirth(dob, completion: { (error) in
                
                self.display?.setSubmitButtonState(.normal)

                guard error == nil else {
                    switch error! {
                    case .fetchFailed(let errorDetail):
                        self.display?.setSubmitButtonState(.disabled)
                        self.displayErrorDetail(errorDetail)
                    default:
                        self.display?.showErrorDialog(error!, retryHandler: {
                            
                            self.submitNewDateOfBirth(dob)
                            
                        })
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
    
    private func updateDateOfBirth(_ dob: String ){

        if !validateInputFields() {
            self.display?.setSubmitButtonState(.disabled)
            return
        }
               
        self.display?.setSubmitButtonState(.progress)

        var formattedBirthDate : String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if let date = dateFormatter.date(from: dob) {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            formattedBirthDate = dateFormatter.string(from: date)
        }
        
        guard formattedBirthDate.count >  0 else { return }
        
        self.editDateOfBirthWorker.updateDateOfBirth(formattedBirthDate) { (error) in
            
            self.display?.setSubmitButtonState(.normal)
            
            guard error == nil else {
                switch error! {
                case .fetchFailed(let errorDetail):
                    self.display?.setSubmitButtonState(.disabled)
                    self.displayErrorDetail(errorDetail)
                default:
                    self.display?.showErrorDialog(error!, retryHandler: {self.updateDateOfBirth(formattedBirthDate)})
                }
                return
            }
            
            dateFormatter.dateFormat = "dd.MM.yyyy"
            if let date = dateFormatter.date(from: dob) {
                self.profile?.birthdate = date
                SCUserDefaultsHelper.setProfile(profile: self.profile!)
            }
            
            SCUtilities.delay(withTime: 0.0, callback: {
                self.display?.dismissView(completion: nil)
            })

        }
    }
    
    
    private func clearDateOfBirth(){

        self.display?.setSubmitButtonState(.disabled)
        self.display?.setClearDOBButtonState(.progress)
        
        self.editDateOfBirthWorker.clearDateOfBirth(completion: { (error) in
            
            self.display?.setSubmitButtonState(.normal)
            self.display?.setClearDOBButtonState(.normal)

            guard error == nil else {
                switch error! {
                case .fetchFailed(let errorDetail):
                    self.display?.setClearDOBButtonState(.disabled)
                    self.displayErrorDetail(errorDetail)
                default:
                    self.display?.showErrorDialog(error!, retryHandler: { self.clearDateOfBirth() })
                }
                return
            }
            
            self.profile?.birthdate = nil
            SCUserDefaultsHelper.setProfile(profile: self.profile!)
            SCUtilities.delay(withTime: 0.0, callback: {
                self.display?.dismissView(completion: nil)
            })

        })
    }
}

extension SCEditDateOfBirthPresenter: SCEditDateOfBirthPresenting {
   
    func setDisplay(_ display: SCEditDateOfBirthDisplaying) {
        self.display = display
    }
    
    func viewDidLoad() {
        debugPrint("SCEditDateOfBirthPresenter->viewDidLoad")
        self.setupUI()
        self.display?.setSubmitButtonState(.disabled)
    }
    
    func viewWillAppear() {
        debugPrint("SCEditDateOfBirthPresenter->viewWillAppear")
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditDateOfBirthPresenter {
    
    
    func confirmWasPressed(){
        //self.injector.trackEvent(eventName: "ClickChangeEmailConfirmBtn")
        if  validateInputFields() {
            if let dob = self.display?.dobFieldContent(), 
                validateInputFields() {
                if let dobFlow = flow, dobFlow == DateOfBirth.registration {
                    completionHandler?(formattedDateOfBirth(dobTxt: dob))
                    self.display?.popViewController()
                } else {
                    self.updateDateOfBirth(dob)
                }
            }
        } else {
            self.display?.setSubmitButtonState(.disabled)
        }
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
    func clearDOBButtonWasPressed() {
        clearDateOfBirth()
    }
    
    fileprivate func formattedDateOfBirth(dobTxt: String) -> String {
        let components = dobTxt.split(separator: ".")
        guard components.count == 3 else { return dobTxt }
        let months = getLocalizedMonths()
        let month = (Int(components[1]) ?? 1) - 1
        return "\(components[0]). \(months[month]) \(components[2])"
    }
}
