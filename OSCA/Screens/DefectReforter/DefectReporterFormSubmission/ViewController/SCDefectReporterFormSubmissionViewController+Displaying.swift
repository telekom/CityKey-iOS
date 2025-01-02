//
//  SCDefectReporterFormSubmissionViewController+Display.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

// MARK: - SCDefectReporterFormSubmissionViewController
extension SCDefectReporterFormSubmissionViewController: SCDefectReporterFormSubmissionViewDisplay {
    
    func setupUI(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, uniqueId: String) {
        thankYouLabel?.text = LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004ThankYouMsg.localized()
        categoryTitleLabel?.text = LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004CategoryLabel.localized()
        categoryLabel?.text = subCategory != nil ? subCategory?.serviceName : category.serviceName
        uniqueIdLabel.text = uniqueId
        reportedOnTitleLabel.text = LocalizationKeys.SCDefectReporterFormSubmissionVC.d004ReportedOnLabel.localized()
        reportedOnLabel.text = defectReportStringFromDate(date: Date())
        feedbackLabel.isHidden = !presenter.showFeedbackLabel()
        okBtnTopConstraint.constant = !presenter.showFeedbackLabel() ? -30 : 30
        okBtn.customizeCityColorStyle()
        okBtn.titleLabel?.adaptFontSize()
        okBtn.setTitle(LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004OkButton.localized(), for: .normal)
        uniqueIdStackView.isHidden = !uniqueId.isSpaceOrEmpty() ? false : true
        switch presenter.getServiceFlow() {
        case .fahrradParken(_):
            thankYouInfoLabel?.text = LocalizationKeys.SCDefectReporterFormSubmissionVC.fa011ThankYouMsg1.localized()
            uniqueIdTitleLabel.text = LocalizationKeys.SCDefectReporterFormSubmissionVC.fa009UniqueIdLabel.localized()
            feedbackLabel.text = LocalizationKeys.SCDefectReporterFormSubmissionVC.fa010SubmitInfoMsg.localized()
        case .defectReporter:
            thankYouInfoLabel?.text = LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004ThankYouMsg1.localized().replacingOccurrences(of: "%s", with: presenter.getCityName()!)
            uniqueIdTitleLabel.text = LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004UniqueIdLabel.localized()
            feedbackLabel.text = LocalizationKeys.SCDefectReporterFormSubmissionVC.d004SubmitInfoMsg.localized()
        }
    }
    
    func setNavigation(title : String) {
        navigationItem.title = title
        navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
    }

    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true)
    }
}
