//
//  SCDefectReporterFormViewController+Setup.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

extension SCDefectReporterFormViewController {
    func setup() {
        setupAccessibilityIDs()
        setupAccessibility()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        
        self.changeLocationBtn.accessibilityIdentifier = "btn_change_location"
        self.sendReportBtn.accessibilityIdentifier = "btn_send_report"
        
        self.addPhotoBtn.accessibilityIdentifier = "btn_add_photo"
        self.addPhotoTitleLabel.accessibilityIdentifier = "lbl_add_photo_title"
        self.addPhotoLabel.accessibilityIdentifier = "lbl_add_photo"
        self.deletePhotoBtn.accessibilityIdentifier = "btn_delete_photo"

        self.termsValidationStateLabel.accessibilityIdentifier = "lbl_terms_validation_state"
        self.termsValidationStateView.accessibilityIdentifier = "img_terms_validation_state"
        self.termsBtn.accessibilityIdentifier = "btn_terms"
        self.termsLabel.accessibilityIdentifier = "lbl_terms"
        
        self.txtfldYourConcern?.accessibilityIdentifier = "tf_your_concern"
        self.txtfldEmail?.accessibilityIdentifier = "tf_email"
        self.txtfldFirstName?.accessibilityIdentifier = "tf_fname"
        self.txtfldLastName?.accessibilityIdentifier = "tf_laname"
        self.txtfldWasteBinID?.accessibilityIdentifier = "tf_waste_bin_id"

        self.termsView.accessibilityIdentifier = "view_terms"
        
        self.locationTitleLabel.accessibilityIdentifier = "lbl_location"
        self.issueDetailLabel.accessibilityIdentifier = "lbl_issue_detail"
        self.reporterDetailLabel.accessibilityIdentifier = "lbl_reporter_detail"
        
        self.noteView.accessibilityIdentifier = "view_note"
        self.noteLabel.accessibilityIdentifier = "lbl_note_label"
        self.noteDescTxtV.accessibilityIdentifier = "tf_note_desc_label"

    }

    private func setupAccessibility(){
        self.navigationItem.backButtonTitle?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.changeLocationBtn.accessibilityTraits = .button
        self.changeLocationBtn.accessibilityLabel = LocalizationKeys.SCDefectReporterFormVC.dr003ChangeLocationButton.localized()
        self.changeLocationBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.sendReportBtn.accessibilityTraits = .button
        self.sendReportBtn.accessibilityLabel = LocalizationKeys.SCDefectReporterFormVC.dr003SendReportLabel1.localized()
        self.sendReportBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        self.addPhotoBtn.accessibilityTraits = .button
        self.addPhotoBtn.accessibilityLabel = LocalizationKeys.SCDefectReporterFormVC.dr003AddPhotoLabel.localized().replacingOccurrences(of: "%s", with: "".localized())
        self.addPhotoBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.addPhotoTitleLabel.accessibilityTraits = .staticText
        self.addPhotoTitleLabel.accessibilityLabel = LocalizationKeys.SCDefectReporterFormVC.dr003AddPhotoLabel.localized().replacingOccurrences(of: "%s", with: LocalizationKeys.SCDefectReporterFormVC.dr003OptionalFieldLabel.localized())
        self.addPhotoTitleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.addPhotoLabel.accessibilityTraits = .staticText
        self.addPhotoLabel.accessibilityLabel = LocalizationKeys.SCDefectReporterFormVC.dr003AddPhotoLabel.localized().replacingOccurrences(of: "%s", with: "".localized())//"dr_003_add_label".localized()
        self.addPhotoLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.deletePhotoBtn.accessibilityTraits = .button
        self.deletePhotoBtn.accessibilityLabel = LocalizationKeys.SCDefectReporterFormVC.dr003DeletePhotoLabel.localized()
        self.deletePhotoBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.termsLabel.accessibilityElementsHidden = true
        self.termsValidationStateLabel.accessibilityElementsHidden = true
        self.termsValidationStateView.image?.accessibilityElementsHidden = true
        
        self.locationTitleLabel.accessibilityTraits = .header
        self.locationTitleLabel.accessibilityLabel = self.locationTitleLabel.text
        self.locationTitleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.issueDetailLabel.accessibilityTraits = .header
        self.issueDetailLabel.accessibilityLabel = self.issueDetailLabel.text
        self.issueDetailLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.reporterDetailLabel.accessibilityTraits = .header
        self.reporterDetailLabel.accessibilityLabel = self.reporterDetailLabel.text
        self.reporterDetailLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.noteLabel.accessibilityTraits = .header
        self.noteLabel.accessibilityLabel = self.noteLabel.text
        self.noteLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        self.noteDescTxtV.accessibilityTraits = .staticText
        self.noteDescTxtV.accessibilityLabel = self.noteDescTxtV.text
        self.noteDescTxtV.accessibilityLanguage = SCUtilities.preferredContentLanguage()

    }
}
