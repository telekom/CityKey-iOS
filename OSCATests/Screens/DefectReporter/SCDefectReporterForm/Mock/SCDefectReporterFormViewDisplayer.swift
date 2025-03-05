/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*///
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
