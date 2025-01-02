extension FahrradparkenReportedLocationDetailVC {
    func setupAccessibility() {
        closeButton.accessibilityTraits = .button
        closeButton.accessibilityLabel = "dialog_button_ok".localized()
        closeButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        moreInformationBtnLabel.accessibilityTraits = .link
        moreInformationBtnLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        mainCategotyLabel.accessibilityTraits = .header
        mainCategotyLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
}
