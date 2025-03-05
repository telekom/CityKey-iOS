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

import UIKit
import GoogleMaps

// MARK: - SCDefectReporterFormViewController
extension SCDefectReporterFormViewController: SCDefectReporterFormViewDisplay {
    
    func setupFormUI(_ subCategory: SCModelDefectSubCategory?) {
        
        self.locationTitleLabel.text = LocalizationKeys.SCDefectReporterFormVC.dr003LocationLabel.localized()
            
        self.changeLocationBtn.customizeCityColorStyleLight()
        self.changeLocationBtn.titleLabel?.adaptFontSize()
        self.changeLocationBtn.setTitle(LocalizationKeys.SCDefectReporterFormVC.dr003ChangeLocationButton.localized(), for: .normal)

        self.sendReportBtn.customizeCityColorStyle()
        self.sendReportBtn.titleLabel?.adaptFontSize()
        self.sendReportBtn.setTitle(LocalizationKeys.SCDefectReporterFormVC.dr003SendReportLabel.localized(), for: .normal)
        
        self.termsLabel.adaptFontSize()
        
        self.termsValidationStateView.image = nil
        self.termsValidationStateLabel.text = ""
        
        self.configureMultiLinksInLabels()
        self.hideKeyboardWhenTappedAround()
        
        self.termsBtn?.setImage(UIImage(named: "checkbox_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
        
        switch presenter.getServiceFlow() {
        case .fahrradParken(_):
            self.issueDetailLabel.isHidden = true
            self.issueDetailLabelTopConstraint.constant = 0
            self.issueDetailLabelBottomConstraint.constant = 0
        default:
            self.issueDetailLabel.attributedText = LocalizationKeys.SCDefectReporterFormVC.dr003DescribeIssueLabel.localized().applyHyphenation()
        }
        
        configureContactSection()
        
        self.configureAddPhotoView()
                
        self.changeLocationView.isHidden = false
        self.changeLocationViewHeightConstraint.constant = !self.changeLocationView.isHidden ? 92 : 0
        
        self.configureNoteView(subCategory)
    }
    
    func setNavigation(title : String) {
        self.navigationItem.title = title
        self.navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
    }
    
    func configureContactSection() {
        
        reporterDetailLabel.attributedText = LocalizationKeys.SCDefectReporterFormVC.dr003YourDetailsLabel.localized().applyHyphenation()
        
        let serviceParamsInfo = presenter.getServiceData().itemServiceParams
        let firstNameParam =  serviceParamsInfo?["field_firstName"] ?? ""
        let lastNameParam = serviceParamsInfo?["field_lastName"] ?? ""
        let emailParam = serviceParamsInfo?["field_email"] ?? ""
        let isContactDetailsNotRequired = firstNameParam == "NOT REQUIRED" && lastNameParam == "NOT REQUIRED" && emailParam == "NOT REQUIRED"
        
        reporterDetailLabel.isHidden = !isContactDetailsNotRequired ? false : true
        reporterDetailStackView.isHidden = !isContactDetailsNotRequired ? false : true
        topSeparatorReporterDetailView.isHidden = !isContactDetailsNotRequired ? false : true
        topSeparatorReporterDetailViewHeightConstraint.constant =  !isContactDetailsNotRequired ? 10 : 0
        
    }

    func configureNoteView(_ subCategory: SCModelDefectSubCategory?){
        
        self.noteLabel.adaptFontSize()
        self.noteDescTxtV.adaptFontSize()
        self.noteLabel.text = LocalizationKeys.SCDefectReporterFormVC.dialogTitleNote.localized()
        
        let noteDescription = getDescriptionForSelectedCategory()
        self.noteView.isHidden = !noteDescription.isSpaceOrEmpty() ? false : true

        let attrString =  noteDescription.htmlAttributedString?.trimmedAttributedString(set: .whitespacesAndNewlines)
        let htmlAttributedString = NSMutableAttributedString(attributedString: attrString!)
        htmlAttributedString.replaceFont(with: self.noteDescTxtV.font!, color: self.noteDescTxtV.textColor!)
        self.noteDescTxtV.attributedText = htmlAttributedString
        self.noteDescTxtV.linkTextAttributes = [.foregroundColor: kColor_cityColor]
        self.noteDescTxtV.textContainerInset = UIEdgeInsets.zero
        self.noteDescTxtV.textContainer.lineFragmentPadding = 0
        
        let heightNoteDescTitle = self.noteDescTxtV.text!.estimatedHeight(withConstrainedWidth: self.noteDescTxtV.frame.width - 40, font: self.noteDescTxtV.font!)
        self.noteViewHeight.constant = !noteDescription.isSpaceOrEmpty() ? CGFloat(heightNoteDescTitle) : 0
        
    }
    
    private func getDescriptionForSelectedCategory() -> String {
        if let subCategoryDescription = subCategory?.description {
            return subCategoryDescription
        } else if let categoryDescription = category?.description {
            return categoryDescription
        }
        return ""
    }
    
    func configureMultiLinksInLabels(){
        
        let checkBoxTerms2Param = self.presenter.getServiceData().itemServiceParams?["field_checkBoxTerms2"]
        let dataPrivacyNoticeLinkParam = self.presenter.getServiceData().itemServiceParams?["dataPrivacyNoticeLink"] ?? ""
        let rulesOfUseLinkParam = self.presenter.getServiceData().itemServiceParams?["rulesOfUseLink"] ?? ""

        if checkBoxTerms2Param == "NOT REQUIRED" {
//            self.termsView.isHidden = true
//            self.updateTermsCheckbox(accepted: true)
        }

        var title = LocalizationKeys.SCDefectReporterFormVC.dr003TermsText.localized()
        
        if !dataPrivacyNoticeLinkParam.isEmpty && !rulesOfUseLinkParam.isEmpty {
            title = LocalizationKeys.SCDefectReporterFormVC.dr003TermsText.localized().replaceStringFormatter()
            self.termsLabel.text = String(format: title,
                                          arguments: [LocalizationKeys.SCDefectReporterFormVC.dr003TermsEndText.localized(),
                                                      LocalizationKeys.SCDefectReporterFormVC.dr003RulesOfUseLink.localized()])
        }else if rulesOfUseLinkParam.isEmpty{
            title = LocalizationKeys.SCDefectReporterFormVC.dr003TermsText.localized().replacingLastOccurrenceOfString("%s", with: "").replaceStringFormatter()
            self.termsLabel.text = String(format: title,
                                          arguments: [LocalizationKeys.SCDefectReporterFormVC.dr003TermsEndText.localized()])
        }
        
        let text = (self.termsLabel.text)!
        let attributedString = NSMutableAttributedString(string: text)
        
        let termsText = LocalizationKeys.SCDefectReporterFormVC.dr003TermsEndText.localized()
        let privacyText = String(LocalizationKeys.SCDefectReporterFormVC.dr003RulesOfUseLink.localized().dropFirst(4))

        _ = attributedString.setTextColor(textToFind: termsText, color: kColor_cityColor)
        _ = attributedString.setTextColor(textToFind: privacyText, color: kColor_cityColor)
       
        self.termsLabel.attributedText = attributedString
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(self.tapTermsLabel(gesture:)))
        self.termsLabel.isUserInteractionEnabled = true
        self.termsLabel.addGestureRecognizer(tapAction)
        
        self.termsValidationStateView.isHidden = true

        self.termsView.accessibilityTraits = .staticText
        self.termsView.accessibilityLabel = self.termsLabel.text
        self.termsView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    @IBAction func tapTermsLabel(gesture: UITapGestureRecognizer) {
        self.presenter.termsWasPressed()

        if gesture.didTapAttributedTextInLabel(label: self.termsLabel, targetText: LocalizationKeys.SCDefectReporterFormVC.dr003TermsEndText.localized()) {
            
            self.presenter.presentTermsAndConditions()
        }
        if gesture.didTapAttributedTextInLabel(label: self.termsLabel, targetText: String(LocalizationKeys.SCDefectReporterFormVC.dr003RulesOfUseLink.localized().dropFirst(4))) {
            
            self.presenter.presentRulesOfUse()
        }

    }
    
    func reloadDefectLocationMap(){
        let latitude = SCUserDefaultsHelper.getDefectLocation().coordinate.latitude
        let longitude = SCUserDefaultsHelper.getDefectLocation().coordinate.longitude
        let camera = GMSCameraPosition(latitude: latitude, longitude: longitude, zoom: zoomFactorMax)
        self.addDefectLocationMarker(latitude: latitude, longitude: longitude)
        self.mapView?.animate(to: camera)
    }
    
    func configureAddPhotoView(){
        
        let uploadImageServiceParam = self.presenter.getServiceData().itemServiceParams?["field_uploadImage"]
    
        switch uploadImageServiceParam {
        case "NOT REQUIRED":
            self.addPhotoContainerView.isHidden = true
            self.addPhotoContainerHeightConstraint.constant = 0
            break
        case "REQUIRED":
            self.addPhotoContainerView.isHidden = false
            self.addPhotoTitleLabel.attributedText = LocalizationKeys.SCDefectReporterFormVC.dr003AddPhotoLabel.localized().replacingOccurrences(of: "%s", with: "".localized()).applyHyphenation()
            self.addPhotoLabel.attributedText = LocalizationKeys.SCDefectReporterFormVC.dr003AddLabel.localized().replacingOccurrences(of: "%s", with: "".localized()).applyHyphenation()
            self.addPhotoContainerHeightConstraint.constant = addPhotoContainerView.frame.size.height
            break
        case "OPTIONAL":
            self.addPhotoContainerView.isHidden = false
            self.addPhotoContainerHeightConstraint.constant = addPhotoContainerView.frame.size.height
            self.addPhotoTitleLabel.attributedText = LocalizationKeys.SCDefectReporterFormVC.dr003AddPhotoLabel.localized().replacingOccurrences(of: "%s", with: LocalizationKeys.SCDefectReporterFormVC.dr003OptionalFieldLabel.localized()).applyHyphenation()
            self.addPhotoLabel.attributedText = LocalizationKeys.SCDefectReporterFormVC.dr003AddLabel.localized().applyHyphenation()
            break
        default:
            self.addPhotoContainerView.isHidden = false
        }
        
        self.addPhotoLabel.textColor = kColor_cityColor
        self.addPhotoView.addBorder(width: 1, color: kColor_cityColor)
        
        self.defectPhotoImageView.isHidden = (self.defectPhotoImageView.image != nil) ? false : true
        self.addPhotoBtn.isHidden = (self.defectPhotoImageView.image != nil) ? true : false
        
        // SMARTC-19418 Client: Design review for citykey App
        self.addPhotoBtn.setImage(UIImage(named: "add_photo")?.maskWithColor(color: kColor_cityColor), for: .normal)
    
        self.activityIndicator.isHidden = true
        if #available(iOS 13.0, *) {
            self.activityIndicator.style = .medium
        } else {
            self.activityIndicator.style = .gray
        }
    }
    
    func setTextFieldContainerViewHeight() {
        self.emailContainerView.isHidden = !(txtfldEmail?.isEnabled() ?? false) ? true : false
        self.emailContainerViewHeight.constant = !(txtfldEmail?.isEnabled() ?? false) ? 0 : textFieldContainerHeight
        self.firstNameContainerView.isHidden = !(txtfldFirstName?.isEnabled() ?? false) ? true : false
        self.firstNameContainerViewHeight.constant = !(txtfldFirstName?.isEnabled() ?? false) ? 0 : textFieldContainerHeight
        self.lastNameContainerView.isHidden = !(txtfldLastName?.isEnabled() ?? false) ? true : false
        self.lastNameContainerViewHeight.constant = !(txtfldLastName?.isEnabled() ?? false) ? 0 : textFieldContainerHeight
        self.wasteBinIDContainerView.isHidden = !(self.subCategory?.isAdditionalInfo ?? false) ? true : false
        self.wasteBinIDContainerViewHeight.constant = !(self.subCategory?.isAdditionalInfo ?? false) ? 0 : textFieldContainerHeight
    }

    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true)
        completionAfterDismiss?()
    }

    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func present(viewController: UIViewController) {
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        self.present(viewController, animated: true)
    }
    
    func setDisallowedCharacterForEMail(_ disallowedChars: String) {
        self.txtfldEmail?.disallowedCharacters = disallowedChars
    }

    func dismissView(animated flag: Bool, completion: (() -> Void)? = nil){
        self.navigationController?.dismiss(animated: flag, completion: completion)
    }
    
    func setSendReportButtonState(_ state : SCCustomButtonState){
        self.sendReportBtn.btnState = state
    }
    
    func getValue(for inputField: SCDefectReporterInputFields) -> String?{
        if let textField = self.textField(for: inputField) as? SCTextfieldComponent{
            return textField.text
        } else if let textView = self.textField(for: inputField) as? SCTextViewComponent{
            return !textView.placeholderLabel.isHidden ? textView.text : ""
        }else{
            return ""
        }
    }
    
    func getFieldType(for inputField: SCDefectReporterInputFields) -> SCTextfieldComponentType{
        
        if let textField = self.textField(for: inputField) as? SCTextfieldComponent{
            return textField.textfieldType
        }else if let textView = self.textField(for: inputField) as? SCTextViewComponent{
            return textView.textViewType
        }else{
            return .text
        }
    }
    
    func getValidationState(for inputField: SCDefectReporterInputFields) -> SCTextfieldValidationState{
        if let textField = self.textField(for: inputField) as? SCTextfieldComponent{
            return textField.validationState
        } else if let textView = self.textField(for: inputField) as? SCTextViewComponent{
            return textView.validationState
        }else{
            return .unmarked
        }
    }
    
    func hideError(for inputField: SCDefectReporterInputFields){
        if let textField = self.textField(for: inputField) as? SCTextfieldComponent{
            textField.hideError()
            textField.validationState = .unmarked
        }
        if let textView = self.textField(for: inputField) as? SCTextViewComponent{
            textView.hideError()
            textView.validationState = .unmarked
        }
    }
    
    func setEnable(for inputField: SCDefectReporterInputFields, enabled : Bool ){
        if let textField = self.textField(for: inputField) as? SCTextfieldComponent{
            textField.setEnabled(enabled)
        }
        if let textView = self.textField(for: inputField) as? SCTextViewComponent{
            textView.setEnabled(enabled)
        }
    }
    
    func showError(for inputField: SCDefectReporterInputFields, text: String){
        if let textField = self.textField(for: inputField) as? SCTextfieldComponent{
            textField.showError(message: text)
        }
        if let textView = self.textField(for: inputField) as? SCTextViewComponent{
            textView.showError(message: text)
        }
        self.updateValidationState(for: inputField, state: .wrong)
    }

    func scrollContent(to inputField: SCDefectReporterInputFields){
        if let textField = self.textField(for: inputField) as? SCTextfieldComponent{
            self.scrollComponentToVisibleArea(component: textField)
        }
        if let textView = self.textField(for: inputField) as? SCTextViewComponent{
            self.scrollComponentToVisibleArea(component: textView)
        }
    }

    func showMessagse(for inputField: SCDefectReporterInputFields, text: String, color: UIColor){
        if let textField = self.textField(for: inputField) as? SCTextfieldComponent{
            textField.show(message: text, color: color)
        }
        if let textView = self.textField(for: inputField) as? SCTextViewComponent{
            textView.show(message: text, color: color)
        }
    }
    
    func deleteContent(for inputField: SCDefectReporterInputFields){
        if let textField = self.textField(for: inputField) as? SCTextfieldComponent{
            textField.deleteContent()
        }
        if let textView = self.textField(for: inputField) as? SCTextViewComponent{
            textView.deleteContent()
        }
    }
    
    func updateValidationState(for inputField: SCDefectReporterInputFields, state: SCTextfieldValidationState){
        
        
        if let textField = self.textField(for: inputField) as? SCTextfieldComponent{
            textField.validationState = state
            
            if state == .ok{
                textField.setLineColor(UIColor(named: "CLR_LABEL_TEXT_GREEN")!)
            }
        }
        if let textView = self.textField(for: inputField) as? SCTextViewComponent{
            textView.validationState = state
            
            if state == .ok{
                textView.setLineColor(UIColor(named: "CLR_LABEL_TEXT_GREEN")!)
            }
        }
    }
    
    func updateTermsValidationState(_ accepted : Bool, showErrorInfoWhenNotAccepted: Bool){
        self.termsValidationStateLabel.text = nil
        self.termsValidationStateView.image = nil
        if !accepted {
            if showErrorInfoWhenNotAccepted{
                self.termsValidationStateLabel.text = LocalizationKeys.SCDefectReporterFormVC.r001RegistrationLabelConsentRequired.localized()
                self.termsValidationStateLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
                self.termsValidationStateView.image = UIImage(named: "icon_val_error")
                self.termsValidationStateLabel.accessibilityElementsHidden = false
                self.termsValidationStateLabel.accessibilityTraits = .staticText
                self.termsValidationStateLabel.accessibilityLabel = LocalizationKeys.SCDefectReporterFormVC.r001RegistrationLabelConsentRequired.localized().localized()
                self.termsValidationStateLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
           }
        } else {
            self.termsValidationStateView.image = UIImage(named: "icon_val_ok")
            self.termsValidationStateLabel.accessibilityElementsHidden = true
        }
        
    }
    
    func updateTermsCheckbox(accepted: Bool) {
        
        self.termsValidationStateLabel.text = nil
        self.termsValidationStateView.image = nil
        
        self.view.endEditing(true)
        
        if accepted {
            self.termsBtn?.setImage(UIImage(named: "checkbox_selected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
        } else {
            self.termsBtn?.setImage(UIImage(named: "checkbox_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
        }
    }
    
    func getDefectImage() -> UIImage? {
        return self.defectPhotoImageView.image
    }
    
    func getDefectImageData() -> Data? {
        return self.defectImageData
    }
    
    private func textField(for inputField: SCDefectReporterInputFields) -> UIViewController?{ //SCTextfieldComponent?{
        switch inputField {
        case .yourconcern:
            return self.txtfldYourConcern
        case .email:
            return self.txtfldEmail
        case .fname:
            return self.txtfldFirstName
        case .lname:
            return self.txtfldLastName
        case .wastebinid:
            return self.txtfldWasteBinID
        }
    }
    
    func moveAccessibilityFocus() {
        UIAccessibility.post(notification: .layoutChanged, argument: changeLocationBtn)
    }
    
}
