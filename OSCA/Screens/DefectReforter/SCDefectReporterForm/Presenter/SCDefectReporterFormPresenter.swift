//
//  SCDefectReporterFormPresenter.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 09/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import MapKit

class SCDefectReporterFormPresenter {
    
    weak var display: SCDefectReporterFormViewDisplay?
    
    var termsAccepted: Bool = false
    var isUploadImageRequired: Bool = false
    var manadatoryFields: [SCDefectReporterInputFields] = []
    var allFields: [SCDefectReporterInputFields] = []

    let injector: SCAdjustTrackingInjection & SCDefectReporterInjecting
    private let appContentSharedWorker: SCAppContentSharedWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    var category: SCModelDefectCategory?
    var subCategory: SCModelDefectSubCategory?
    var profile: SCModelProfile?
    private let serviceDetail: SCServiceDetailProvider

    let serviceData: SCBaseComponentItem

    private var sentDefectRequest: SCModelDefectRequest?
    let auth: SCAuthStateProviding
    let mainQueue: Dispatching
    let serviceFlow: Services

    init(serviceData: SCBaseComponentItem,
         injector: SCAdjustTrackingInjection & SCDefectReporterInjecting,
         appContentSharedWorker: SCAppContentSharedWorking,
         cityContentSharedWorker: SCCityContentSharedWorking,
         userContentSharedWorker: SCUserContentSharedWorking,
         category: SCModelDefectCategory,
         subCategory: SCModelDefectSubCategory? = nil,
         auth: SCAuthStateProviding = SCAuth.shared,
         mainQueue: Dispatching = DispatchQueue.main,
         serviceDetail: SCServiceDetailProvider,
         serviceFlow: Services) {

        self.injector = injector
        self.appContentSharedWorker = appContentSharedWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.category = category
        self.subCategory = subCategory
        self.serviceData = serviceData
        self.auth = auth
        self.mainQueue = mainQueue
        self.serviceDetail = serviceDetail
        self.serviceFlow = serviceFlow
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    private func setupNotifications() {
        SCDataUIEvents.registerNotifications(for: self, on: .didChangeDefectLocation, with: #selector(refreshUIContent))
    }
    
    @objc private func refreshUIContent() {
        self.display?.reloadDefectLocationMap()
    }
    
    func setupUI() {

        self.display?.setNavigation(title: self.subCategory != nil ? self.subCategory!.serviceName : self.category!.serviceName)
        self.display?.setDisallowedCharacterForEMail(" ")
        self.display?.setupFormUI(self.subCategory)
    }
    
    
    func setProfileData(){
        if auth.isUserLoggedIn() {
            if self.userContentSharedWorker.isUserDataAvailable() {
                if let userData = self.userContentSharedWorker.getUserData() {
                    self.profile = userData.profile
                }
            }
        }
    }
    
    func displayError(_ error: SCWorkerError) {
        self.display?.showErrorDialog(error)
    }
    
    
    func textFieldComponentDidChange(for inputField: SCDefectReporterInputFields) {
        
        // For all other fields hide error when changing content
        self.display?.hideError(for: inputField)
        
        self.updateSendReportButtonState()
    }
    
    func txtFieldEditingDidEnd(value : String, inputField: SCDefectReporterInputFields, textFieldType: SCTextfieldComponentType) {
        // when leaving a field we need to validate it directly
        
        if inputField == .email && manadatoryFields.contains(inputField){
            let validationResult = SCInputValidation.isInputValid(value , fieldType: textFieldType)
            if !validationResult.isValid {
                self.display?.showError(for: inputField, text: validationResult.message ?? "Unknown error")
                self.display?.updateValidationState(for: inputField, state: .wrong)
            }
        }else if inputField == .yourconcern && manadatoryFields.contains(inputField){
            let inputValue = !value.contains(LocalizationKeys.SCDefectReporterFormPresenter.dr003YourConcernHint.localized()) ? value : ""
            let validationResult = SCInputValidation.isInputValid(inputValue , fieldType: textFieldType)
            if !validationResult.isValid {
                self.display?.showError(for: inputField, text: validationResult.message ?? "Unknown error")
                self.display?.updateValidationState(for: inputField, state: .wrong)
            }
        } else if inputField == .email && !value.isEmpty {
            let validationResult = SCInputValidation.isInputValid(value , fieldType: textFieldType)
            if !validationResult.isValid {
                self.display?.showError(for: inputField, text: validationResult.message ?? "Unknown error")
                self.display?.updateValidationState(for: inputField, state: .wrong)
            }
        }
        
        self.updateSendReportButtonState()
    }

    func updateSendReportButtonState() {
        if isPreviewMode {
            self.display?.setSendReportButtonState(.disabled)
            return
        }

        self.display?.setSendReportButtonState(.normal)
        
        let textFields = self.manadatoryFields
        
        // check all textfields if they are valid
        for textField in textFields {
            if (self.display?.getValue(for: textField) ?? ""  ).isEmpty || self.display?.getValidationState(for: textField) == .wrong{
                self.display?.setSendReportButtonState(.disabled)
            }else if textField == .yourconcern{
                let text = self.display?.getValue(for: textField)
                let inputValue = !text!.contains(LocalizationKeys.SCDefectReporterFormPresenter.dr003YourConcernHint.localized().replacingOccurrences(of: "%s", with: "".localized())) ? text : ""
                if inputValue!.isEmpty || self.display?.getValidationState(for: textField) == .wrong{
                    self.display?.setSendReportButtonState(.disabled)
                }
            }
        }
        
        if let _ = self.display?.getValue(for: .email)?.isEmpty,
           !manadatoryFields.contains(.email),
           self.display?.getValidationState(for: .email) == .wrong  {
            self.display?.setSendReportButtonState(.disabled)
        }
    }

    func isErrorHandled(_ detail : SCWorkerErrorDetails) -> Bool {
        let errorCode = detail.errorCode ?? ""
        guard SCHandledRegistrationError(rawValue: errorCode) != nil else {
            return false
        }
        return true
    }
    
    private func displayErrorDetail(_ detail : SCWorkerErrorDetails){
        let error = detail.errorCode ?? ""
        switch error {
        case "email.validation.error":
            self.display?.showError(for: .email, text: detail.message)
            self.display?.scrollContent(to: .email)
        case "user.email.not.valid":
            self.display?.showError(for: .email, text: detail.message)
            self.display?.scrollContent(to: .email)
        case "user.email.exists":
            self.display?.showError(for: .email, text: detail.message)
            self.display?.scrollContent(to: .email)
        case "user.email.not.verified":
            self.display?.showError(for: .email, text: detail.message)
            self.display?.scrollContent(to: .email)
        default:
            self.display?.showErrorDialog(with: detail.message, retryHandler : nil, showCancelButton: false, additionalButtonTitle: nil, additionButtonHandler: nil)
            break
        }
    }
    
    
    func startSendReport(defectLocation: LocationDetails? = nil){
            
        var valid = true
        
        // all data fields
        let textFields = self.manadatoryFields
    
        for textField in textFields {
            self.display?.hideError(for: textField)
            self.display?.updateValidationState(for: textField, state: .unmarked)

            let validationResult = SCInputValidation.isInputValid(self.display?.getValue(for: textField) ?? "" , fieldType: self.display?.getFieldType(for: textField) ?? .text)
            if validationResult.isValid {
                
            } else {
                self.display?.showError(for: textField, text: validationResult.message ?? "Unknown error")
                self.display?.updateValidationState(for: textField, state: .wrong)
                valid = false
            }
        }
        
        //handle invalid email id when email field is optional and non empty
        if let _ = self.display?.getValue(for: .email)?.isEmpty,
           !manadatoryFields.contains(.email),
           self.display?.getValidationState(for: .email) == .wrong  {
            let validationResult = SCInputValidation.isInputValid(self.display?.getValue(for: .email) ?? "",
                                                                  fieldType: self.display?.getFieldType(for: .email) ?? .text)
            self.display?.showError(for: .email, text: validationResult.message ?? "Unknown error")
            self.display?.updateValidationState(for: .email, state: .wrong)
            valid = false
        }
        
        // check terms and privcy and upload image
        let uploadImageServiceParam = self.getServiceData().itemServiceParams?["field_uploadImage"]
        self.isUploadImageRequired = uploadImageServiceParam == "REQUIRED" ? true : false
        
        
        if self.isUploadImageRequired && self.display?.getDefectImage() != nil{
            valid = true
        }
        else if !self.isUploadImageRequired || self.display?.getDefectImage() != nil{
            valid = true
        }
        else{
            valid = false
        }
        
        if (!self.termsAccepted){
            valid = false
        }

        self.display?.updateTermsValidationState(self.termsAccepted, showErrorInfoWhenNotAccepted: true)

        if (!self.termsAccepted){
            valid = false
        }
        
        if valid && self.display?.getDefectImage() != nil{
            
            self.sendImage(defectLocation: defectLocation)
            
        } else if valid && self.display?.getDefectImage() == nil{
            self.sendReport(mediaUrl: "", defectLocation: defectLocation)
        }
        else{
            self.updateSendReportButtonState()
        }
    }
    
    private func sendImage(defectLocation: LocationDetails? = nil) {
        
        self.display?.setSendReportButtonState(.progress)
        
        self.display?.dismissKeyboard()

        let cityId = cityContentSharedWorker.getCityID()

        serviceDetail.uploadDefectImage(cityId: "\(cityId)", imageData: (self.display?.getDefectImageData())!) { [weak self] (mediaUrl, error) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.mainQueue.async {
                strongSelf.display?.setSendReportButtonState(.disabled)
                
                guard error == nil else {
                    if  case .noInternet = error! {
                        strongSelf.display?.showErrorDialog(SCWorkerError.noInternet,
                                                            retryHandler: nil, showCancelButton: true,
                                                            additionalButtonTitle: nil,
                                                            additionButtonHandler: nil)
                    }
                    else if case .fetchFailed(let errorDetail) = error{
                        SCUtilities.topViewController().showUIAlert(with: errorDetail.message,
                                                                    cancelTitle: LocalizationKeys.SCDefectReporterFormPresenter.dr003DialogButtonOk.localized(),
                                                                    retryTitle: nil,
                                                                    retryHandler: nil,
                                                                    additionalButtonTitle: nil,
                                                                    additionButtonHandler: nil,
                                                                    alertTitle: strongSelf.getAlertTitle())
                    }
                    else{
                        strongSelf.display?.showErrorDialog(error!, retryHandler: nil, showCancelButton: true)
                    }
                    strongSelf.updateSendReportButtonState()
                    return
                }

                strongSelf.sendReport(mediaUrl: mediaUrl ?? "", defectLocation: defectLocation)

                return
            }
        }
    }
    
    private func sendReport(mediaUrl: String, defectLocation: LocationDetails? = nil){
        
        let eMail = (self.display?.getValue(for: .email) ?? "").trimmingCharacters(in: .whitespaces)
        let firstName = self.display?.getValue(for: .fname) ?? ""
        let lastName = self.display?.getValue(for: .lname) ?? ""
        let description = self.display?.getValue(for: .yourconcern) ?? ""
        let wasteBinId = self.display?.getValue(for: .wastebinid) ?? ""

        self.display?.setSendReportButtonState(.progress)
        
        self.display?.dismissKeyboard()

        let cityId = cityContentSharedWorker.getCityID()
        
        let defectRequestData = SCModelDefectRequest(lastName: lastName,
                                                     firstName: firstName,
                                                     serviceCode: self.category?.serviceCode ?? "",
                                                     lat: String(self.getDefectLocation().coordinate.latitude),
                                                     long: String(self.getDefectLocation().coordinate.longitude),
                                                     email: eMail,
                                                     description: description,
                                                     mediaUrl: mediaUrl,
                                                     wasteBinId: wasteBinId,
                                                     subServiceCode: self.subCategory?.serviceCode ?? "",
                                                     location: defectLocation?.locationAddress ?? "",
                                                     streetName: defectLocation?.streetName ?? "",
                                                     houseNumber: defectLocation?.houseNumber ?? "",
                                                     postalCode: defectLocation?.postalCode ?? "",
                                                     phoneNumber: "")

        serviceDetail.submitDefect(cityId: "\(cityId)", defectRequest: defectRequestData) { [weak self] (uniqueId, error) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.mainQueue.async {
                strongSelf.display?.setSendReportButtonState(.disabled)
                
                guard error == nil else {
                    switch error! {
                    case .fetchFailed(let errorDetail):
                        switch errorDetail.errorCode {
                        case "service.inactive":
                            SCUtilities.topViewController().showUIAlert(with: LocalizationKeys.SCDefectReporterFormPresenter.dr003DefectSubmissionError.localized(),
                                                                        cancelTitle: LocalizationKeys.SCDefectReporterFormPresenter.dr003DialogButtonOk.localized(),
                                                                        retryTitle: nil, retryHandler: nil,
                                                                        additionalButtonTitle: nil, additionButtonHandler: nil,
                                                                        alertTitle: strongSelf.getAlertTitle())
                        case "defect_outside_city",
                            "defect_already_reported",
                            "defect.not.found",
                            "multiple.defect.already.reported",
                            "duplicate.defect":
                            SCUtilities.topViewController().showUIAlert(with: errorDetail.message,
                                                                        cancelTitle: LocalizationKeys.SCDefectReporterFormPresenter.dr003DialogButtonOk.localized(), retryTitle: nil,
                                                                        retryHandler: nil, additionalButtonTitle: nil, additionButtonHandler: nil,
                                                                        alertTitle: strongSelf.getAlertTitle())
                            
                        default:
                            SCUtilities.topViewController().showUIAlert(with: LocalizationKeys.SCDefectReporterFormPresenter.dr003DefectSubmissionError.localized(),
                                                                        cancelTitle: LocalizationKeys.SCDefectReporterFormPresenter.dr003DialogButtonOk.localized(),
                                                                        retryTitle: nil, retryHandler: nil, additionalButtonTitle: nil,
                                                                        additionButtonHandler: nil,
                                                                        alertTitle: strongSelf.getAlertTitle())
                        }
                    default:
                        SCUtilities.topViewController().showUIAlert(with: LocalizationKeys.SCDefectReporterFormPresenter.dr003DefectSubmissionError.localized(),
                                                                    cancelTitle: LocalizationKeys.SCDefectReporterFormPresenter.dr003DialogButtonOk.localized(),
                                                                    retryTitle: nil, retryHandler: nil,
                                                                    additionalButtonTitle: nil, additionButtonHandler: nil,
                                                                    alertTitle: strongSelf.getAlertTitle())
                    }
                    strongSelf.updateSendReportButtonState()
                    return
                }

                strongSelf.sentDefectRequest = defectRequestData
                strongSelf.submitDefectWasSuccessful(uniqueId: uniqueId)
                return
            }
        }
        
    }
    
    private func submitDefectWasSuccessful(uniqueId : String?){
        
        let textFields = self.allFields

        for textField in textFields {

            let validationResult = SCInputValidation.isInputValid(self.display?.getValue(for: textField) ?? "" , fieldType: self.display?.getFieldType(for: textField) ?? .text)
            if validationResult.isValid {
                self.display?.updateValidationState(for: textField, state: .ok)
            }
        }
        
        self.display?.setSendReportButtonState(.disabled)

        SCUtilities.delay(withTime: 2.0, callback: {
            let email = self.display?.getValue(for: .email)
            let controller = self.injector.getDefectReporterFormSubmissionViewController(category: self.category!,
                                                                                         subCategory: self.subCategory,
                                                                                         uniqueId: uniqueId ?? "",
                                                                                         serviceFlow: self.serviceFlow,
                                                                                         email: email)
            self.display?.push(viewController: controller)
        })

    }
    
    private func getAlertTitle() -> String? {
        switch serviceFlow {
        case .defectReporter:
            return LocalizationKeys.SCDefectReporterFormPresenter.dr003DefectSubmissionErrorTitle.localized()
        case .fahrradParken(_):
            return nil
        }
    }
}
