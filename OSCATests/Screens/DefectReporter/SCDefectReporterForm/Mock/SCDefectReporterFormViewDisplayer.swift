//
//  SCDefectReporterFormViewDisplayer.swift
//  OSCATests
//
//  Created by Bhaskar N S on 27/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCDefectReporterFormViewDisplayer: SCDefectReporterFormViewDisplay {
    private(set) var navTitle: String = ""
    private(set) var isSetNavigationCalled: Bool = false
    private(set) var isSetupFormUICalled: Bool = false
    private(set) var isSetDisallowedCharacterForEMail: Bool = false
    private(set) var isShowErrorDialog: Bool = false
    private(set) var isHideErrorCalled: Bool = false
    private(set) var inputField: SCDefectReporterInputFields = .yourconcern
    private(set) var sendButtonState: SCCustomButtonState?
    private(set) var isPresentCalled: Bool = false
    private(set) var isDismissCalled: Bool = false
    private(set) var isUpdateValidationState = true
    private(set) var isDismissKeyboardCalled = true

    func setDisallowedCharacterForEMail(_ disallowedChars: String) {
        isSetDisallowedCharacterForEMail = true
    }
    
    func dismissView(animated flag: Bool, completion: (() -> Void)?) {
        isDismissCalled = true
    }
    
    func dismissKeyboard() {
        isDismissKeyboardCalled = true
    }
    
    func setSendReportButtonState(_ state: SCCustomButtonState) {
        sendButtonState = state
    }
    
    func getValue(for inputField: SCDefectReporterInputFields) -> String? {
        "Not Empty"
    }
    
    func getFieldType(for inputField: SCDefectReporterInputFields) -> SCTextfieldComponentType {
        .birthdate
    }
    
    func hideError(for inputField: SCDefectReporterInputFields) {
        self.inputField = inputField
        isHideErrorCalled = true
    }
    
    func showError(for inputField: SCDefectReporterInputFields, text: String) {
        
    }
    
    func showMessagse(for inputField: SCDefectReporterInputFields, text: String, color: UIColor) {
        
    }
    
    func scrollContent(to inputField: SCDefectReporterInputFields) {
        
    }
    
    func deleteContent(for inputField: SCDefectReporterInputFields) {
        
    }
    
    func updateValidationState(for inputField: SCDefectReporterInputFields, state: SCTextfieldValidationState) {
        isUpdateValidationState = true
    }
    
    func getValidationState(for inputField: SCDefectReporterInputFields) -> SCTextfieldValidationState {
        .warning
    }
    
    func setEnable(for inputField: SCDefectReporterInputFields, enabled: Bool) {
        
    }
    
    func updateTermsValidationState(_ accepted: Bool, showErrorInfoWhenNotAccepted: Bool) {
        
    }
    
    func updateTermsCheckbox(accepted: Bool) {
        
    }
    
    func setTextFieldContainerViewHeight() {
        
    }
    
    func getDefectImage() -> UIImage? {
        nil
    }
    
    func getDefectImageData() -> Data? {
        nil
    }
    
    func dismiss(completion: (() -> Void)?) {
        
    }
    
    func setNavigation(title: String) {
        self.navTitle = title
        isSetNavigationCalled = true
    }
    
    func setupFormUI(_ subCategory: SCModelDefectSubCategory?) {
        isSetupFormUICalled = true
    }
    
    func reloadDefectLocationMap() {
        
    }
    
    func push(viewController: UIViewController) {
        
    }
    
    func present(viewController: UIViewController) {
        isPresentCalled = true
    }
    func showErrorDialog(_ error: SCWorkerError, retryHandler : (() -> Void)? = nil, showCancelButton: Bool? = true, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil) {
        isShowErrorDialog = true
    }
    func moveAccessibilityFocus() {
        
    }
}
