//
//  SCDefectReporterForm.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import CoreLocation

protocol SCDefectReporterFormViewDisplay : AnyObject, SCDisplaying {
    
    func setDisallowedCharacterForEMail(_ disallowedChars: String)
    func dismissView(animated flag: Bool, completion: (() -> Void)?)
    func dismissKeyboard()
    func setSendReportButtonState(_ state : SCCustomButtonState)
    
    func getValue(for inputField: SCDefectReporterInputFields) -> String?
    func getFieldType(for inputField: SCDefectReporterInputFields) -> SCTextfieldComponentType
    func hideError(for inputField: SCDefectReporterInputFields)
    func showError(for inputField: SCDefectReporterInputFields, text: String)
    func showMessagse(for inputField: SCDefectReporterInputFields, text: String, color: UIColor)
    func scrollContent(to inputField: SCDefectReporterInputFields)
    func deleteContent(for inputField: SCDefectReporterInputFields)
    func updateValidationState(for inputField: SCDefectReporterInputFields, state: SCTextfieldValidationState)
    func getValidationState(for inputField: SCDefectReporterInputFields) -> SCTextfieldValidationState
    func setEnable(for inputField: SCDefectReporterInputFields,enabled : Bool )
    func updateTermsValidationState(_ accepted : Bool, showErrorInfoWhenNotAccepted: Bool)
    func updateTermsCheckbox(accepted: Bool)
    func setTextFieldContainerViewHeight()
    func getDefectImage() -> UIImage?
    func getDefectImageData() -> Data?

    func dismiss(completion: (() -> Void)?)
    func setNavigation(title : String)
    func setupFormUI(_ subCategory: SCModelDefectSubCategory?)
    func reloadDefectLocationMap()
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func moveAccessibilityFocus()
    
}
protocol SCDefectReporterFormPresenting: SCPresenting {
    func setDisplay(_ display: SCDefectReporterFormViewDisplay)
    
    func configureField(_ field: SCTextFieldConfigurable?, identifier: String?, type: SCDefectReporterInputFields, autocapitalizationType: UITextAutocapitalizationType) -> SCTextFieldConfigurable?
    
    func textFieldComponentDidChange(for inputField: SCDefectReporterInputFields)
    func txtFieldEditingDidEnd(value : String, inputField: SCDefectReporterInputFields, textFieldType: SCTextfieldComponentType)
    func termsWasPressed()
    func presentTermsAndConditions()
    func presentRulesOfUse()
    func changeLocationBtnWasPressed()
    func sendReportBtnWasPressed(defectLocation: LocationDetails?)
    func getDefectLocation() -> CLLocation
    func getServiceData() -> SCBaseComponentItem
    func setManadatoryFields() -> [SCDefectReporterInputFields]
    func updateManadatoryFields(_ field: SCDefectReporterInputFields)
    func getProfileData() -> SCModelProfile?
    func updateSendReportBtnState()
    func getServiceFlow() -> Services
}
