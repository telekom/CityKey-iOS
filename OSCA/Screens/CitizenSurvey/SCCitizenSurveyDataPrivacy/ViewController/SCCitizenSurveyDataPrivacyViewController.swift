//
//  SCCitizenSurveyDataPrivacyViewController.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 12/01/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import WebKit

class SCCitizenSurveyDataPrivacyViewController: UIViewController {

    @IBOutlet weak var dataPrivacyTextView: UITextView!
    @IBOutlet weak var dataPrivacyAcceptButton: SCCustomButton!

    var presenter: SCCitizenSurveyDataPrivacyPresenting?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        handleDynamicTypeChange()
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicTypeChange))
    }

    private func setup() {
        self.title = LocalizationKeys.SCCitizenSurveyDataPrivacyViewController.dataPrivacySurveyTitle.localized()
        dataPrivacyTextView.layoutManager.hyphenationFactor = 1.0
        dataPrivacyTextView.attributedText = presenter?.getDataPrivacyContent()

        dataPrivacyAcceptButton.setTitle(LocalizationKeys.SCCitizenSurveyDataPrivacyViewController.dataPrivacySurveyButtonText.localized(), for: .normal)
        dataPrivacyAcceptButton.customizeCityColorStyle()
    }
    
    @objc private func handleDynamicTypeChange() {
        dataPrivacyTextView.adjustsFontForContentSizeCategory = true
        dataPrivacyTextView.attributedText = presenter?.getDataPrivacyContent()
        dataPrivacyAcceptButton.titleLabel?.adjustsFontForContentSizeCategory = true
        dataPrivacyAcceptButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17.0, maxSize: 28.0)
    }

    @IBAction func didTapOnAccept(_ sender: UIButton) {
        presenter?.setDataPrivacyAccepted()
        dismiss(animated: true) {
            [weak self] in
            self?.presenter?.informDataPrivacyAccepted()
        }
    }

    @IBAction func didTapOnClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
