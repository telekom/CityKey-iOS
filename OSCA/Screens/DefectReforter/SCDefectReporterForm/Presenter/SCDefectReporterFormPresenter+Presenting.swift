//
//  SCDefectReporterFormPresenter+Presenting.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
