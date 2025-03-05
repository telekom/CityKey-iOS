/*
Created by Bhaskar N S on 21/07/22.
Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import CoreLocation
import UIKit

extension SCDefectReporterFormPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.setupUI()
        self.display?.setSendReportButtonState(.disabled)
        self.updateSendReportButtonState()

    }
    
    func viewDidAppear() {
        self.setProfileData()
        if self.manadatoryFields.contains(.email){
            self.updateSendReportButtonState()
        }
    }
}

extension SCDefectReporterFormPresenter : SCDefectReporterFormPresenting {
    
    func setDisplay(_ display: SCDefectReporterFormViewDisplay) {
        self.display = display
    }
    
    func configureField(_ field: SCTextFieldConfigurable?, identifier: String?, type: SCDefectReporterInputFields, autocapitalizationType: UITextAutocapitalizationType) -> SCTextFieldConfigurable?
    {
        guard let textfield = field, let identifier = identifier else {
            return nil
        }
        
        var isManadatoryField : Bool = false
        
        switch identifier {
            
        case "sgtxtfldEmail":
            if type == .email {
                isManadatoryField = self.setupFieldsVisibility(self.serviceData.itemServiceParams?["field_email"] ?? "", textfield: textfield, placeholderText: LocalizationKeys.SCDefectReporterFormPresenter.dr003EmailAddressHint.localized(), fieldType: .email)
                if isManadatoryField {
                    self.manadatoryFields.append(type)
                }
                self.allFields.append(type)
                return textfield
            }
            
        case "sgtxtfldFirstName":
            if type == .fname {
                isManadatoryField = self.setupFieldsVisibility(self.serviceData.itemServiceParams?["field_firstName"] ?? "", textfield: textfield, placeholderText: LocalizationKeys.SCDefectReporterFormPresenter.dr003FirstNameHint.localized(), fieldType: .text)
                if isManadatoryField {
                    self.manadatoryFields.append(type)
                }
                self.allFields.append(type)
                return textfield
            }
            
        case "sgtxtfldLastName":
            if type == .lname {
                isManadatoryField = self.setupFieldsVisibility(self.serviceData.itemServiceParams?["field_lastName"] ?? "", textfield: textfield, placeholderText: LocalizationKeys.SCDefectReporterFormPresenter.dr003LastNameHint.localized(), fieldType: .text)
                if isManadatoryField {
                    self.manadatoryFields.append(type)
                }
                self.allFields.append(type)
                return textfield
            }
            
        case "sgtxtfldYourConcern":
            if type == .yourconcern{
                switch serviceFlow {
                case .fahrradParken(_):
                    isManadatoryField = self.setupFieldsVisibility(self.serviceData.itemServiceParams?["field_yourConcern"] ?? "",
                                                                   textfield: textfield,
                                                                   placeholderText: LocalizationKeys.SCDefectReporterFormPresenter.fa003DescribeIssueLabel.localized(),
                                                                   fieldType: .text,
                                                                   disclaimerText: LocalizationKeys.SCDefectReporterFormPresenter.dr003YourConcernDisclaimer.localized())
                default:
                    isManadatoryField = self.setupFieldsVisibility(self.serviceData.itemServiceParams?["field_yourConcern"] ?? "",
                                                                   textfield: textfield, placeholderText: LocalizationKeys.SCDefectReporterFormPresenter.dr003YourConcernHint.localized(), fieldType: .text,
                                                                   disclaimerText: LocalizationKeys.SCDefectReporterFormPresenter.dr003YourConcernDisclaimer.localized())
                }
                if isManadatoryField {
                    self.manadatoryFields.append(type)
                }
                self.allFields.append(type)
                return textfield
            }
            
        case "sgtxtfldWasteBinId":
            if type == .wastebinid {
                isManadatoryField = self.setupFieldsVisibility(self.serviceData.itemServiceParams?["field_wasteBinId"] ?? "", textfield: textfield, placeholderText: LocalizationKeys.SCDefectReporterFormPresenter.dr003WasteBinIdHint.localized(), fieldType: .wasteBinId)
                if isManadatoryField {
                    self.manadatoryFields.append(type)
                }
                self.allFields.append(type)
                return textfield
            }
            
        default:
            return nil
        }
        return nil
    }
    
    func setupFieldsVisibility(_ serviceParam: String, textfield: SCTextFieldConfigurable, placeholderText: String, fieldType: SCTextfieldComponentType, disclaimerText: String? = nil) -> Bool{

        var isManadatoryField = false
        
        switch serviceParam {
        case "NOT REQUIRED":
            textfield.setEnabled(false)
            break
        case "REQUIRED":
            textfield.setEnabled(true)
            let maxCharCount = (fieldType == .wasteBinId) ? 4 : (!placeholderText.contains(LocalizationKeys.SCDefectReporterFormPresenter.dr003YourConcernHint.localized()) ? 255 : 500)
            if let disclaimerText = disclaimerText {
                textfield.configure(placeholder: placeholderText.replacingOccurrences(of: "%s", with: "".localized()), fieldType: fieldType, maxCharCount: maxCharCount, autocapitalization: .none, disclaimerText: disclaimerText)
            } else {
                textfield.configure(placeholder: placeholderText.replacingOccurrences(of: "%s", with: "".localized()), fieldType: fieldType, maxCharCount: maxCharCount, autocapitalization: .none)
            }
            isManadatoryField = true
            break
        case "OPTIONAL":
            textfield.setEnabled(true)
            let maxCharCount = (fieldType == .wasteBinId) ? 4 : (!placeholderText.contains(LocalizationKeys.SCDefectReporterFormPresenter.dr003YourConcernHint.localized()) ? 255 : 500)
            if disclaimerText != nil {
                textfield.configure(placeholder: placeholderText.replacingOccurrences(of: "%s", with: LocalizationKeys.SCDefectReporterFormPresenter.dr003OptionalFieldLabel.localized()), fieldType: fieldType, maxCharCount: maxCharCount, autocapitalization: .none, disclaimerText: disclaimerText)
            } else {
                textfield.configure(placeholder: placeholderText.replacingOccurrences(of: "%s", with: LocalizationKeys.SCDefectReporterFormPresenter.dr003OptionalFieldLabel.localized()), fieldType: fieldType, maxCharCount: maxCharCount, autocapitalization: .none)
            }
            break
        default:
            textfield.setEnabled(false)
        }
        
        return isManadatoryField
    }
    
    func termsWasPressed() {
        self.termsAccepted = !self.termsAccepted
        
        self.display?.updateTermsCheckbox(accepted: self.termsAccepted)
        self.display?.updateTermsValidationState(self.termsAccepted, showErrorInfoWhenNotAccepted: false)
        self.updateSendReportButtonState()
    }
    
    func closeWasPressed() {
        self.display?.dismissView(animated: true, completion:nil)
    }
    
    func presentTermsAndConditions() {
        if let termsAndConditions = self.serviceData.itemServiceParams?["dataPrivacyNoticeLink"]{

            SCInternalBrowser.showURL(termsAndConditions.absoluteUrl(), withBrowserType: .safari, title: LocalizationKeys.SCDefectReporterFormPresenter.dr003TermsTitle.localized())
        }
    }
    
    func presentRulesOfUse() {
        if let rulesOfUse = self.serviceData.itemServiceParams?["rulesOfUseLink"]{

            SCInternalBrowser.showURL(rulesOfUse.absoluteUrl(), withBrowserType: .safari, title: LocalizationKeys.SCDefectReporterFormPresenter.dr005RulesOfUseTitle.localized())
        }
    }
    
    func changeLocationBtnWasPressed() {
        switch serviceFlow {
        case . defectReporter:
            let controller = self.injector.getDefectReporterLocationViewController(category: self.category!, subCategory: self.subCategory, serviceData: self.serviceData, includeNavController: true, service: .defectReporter, completionAfterDismiss: {
                self.display?.moveAccessibilityFocus()
            })
            self.display?.present(viewController: controller)
        case .fahrradParken(_):
            let controller = self.injector.getFahrradparkenReportedLocationViewController(category: self.category!, subCategory: self.subCategory, serviceData: self.serviceData, includeNavController: true, service: serviceFlow) {
                self.display?.moveAccessibilityFocus()
            }
            self.display?.present(viewController: controller)
        }
    }
    
    func sendReportBtnWasPressed(defectLocation: LocationDetails?){
        self.startSendReport(defectLocation: defectLocation)
    }
    
    func getDefectLocation() -> CLLocation {
        return SCUserDefaultsHelper.getDefectLocation()
    }
    
    func getServiceData() -> SCBaseComponentItem {
        return self.serviceData
    }
    
    func setManadatoryFields() -> [SCDefectReporterInputFields] {
        return self.manadatoryFields
    }
    
    func updateManadatoryFields(_ field: SCDefectReporterInputFields) {
        self.manadatoryFields.append(field)
    }
    
    func getProfileData() -> SCModelProfile? {
        return self.profile
    }
    
    func updateSendReportBtnState() {
        self.updateSendReportButtonState()
    }
    
    func getServiceFlow() -> Services {
        return serviceFlow
    }
}
