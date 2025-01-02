//
//  SCDefectReporterFormSubmissionViewController.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 09/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import MoEngageInApps

class SCDefectReporterFormSubmissionViewController: UIViewController {

    public var presenter: SCDefectReporterFormSubmissionPresenting!

    @IBOutlet weak var thankYouLabel: UILabel!
    @IBOutlet weak var thankYouInfoLabel: UILabel!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var uniqueIdTitleLabel: UILabel!
    @IBOutlet weak var uniqueIdLabel: UILabel!
    @IBOutlet weak var reportedOnTitleLabel: UILabel!
    @IBOutlet weak var reportedOnLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var okBtn: SCCustomButton!
    @IBOutlet weak var okBtnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var okBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var uniqueIdStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        handleDynamicTypeChange()
        // Remove the back button and instead show ok button for navigation
        self.navigationItem.hidesBackButton = true
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        
        self.setupAccessibilityIDs()
        self.setupAccessibility()

        
//        //MARK: MoEngage In-App messages - show only for Smart City defect reporter on QA
//        #if INT
////        MOInApp.sharedInstance().setInAppDelegate(self)
//        if presenter.getCityId() == 14 {
//            MOInApp.sharedInstance().setCurrentInAppContexts(["DefectSubmitted"])
//            MOInApp.sharedInstance().showCampaign()
//        }
//        #endif

    }
    
    
    private func handleDynamicTypeChange() {
        thankYouLabel.adjustsFontForContentSizeCategory = true
        thankYouLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 21, maxSize: 50)
        thankYouInfoLabel.adjustsFontForContentSizeCategory = true
        thankYouInfoLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 40)
        categoryTitleLabel.adjustsFontForContentSizeCategory = true
        categoryTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16, maxSize: 40)
        categoryLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 40)
        uniqueIdTitleLabel.adjustsFontForContentSizeCategory = true
        uniqueIdTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16, maxSize: 40)
        uniqueIdLabel.adjustsFontForContentSizeCategory = true
        uniqueIdLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 40)
        reportedOnTitleLabel.adjustsFontForContentSizeCategory = true
        reportedOnTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16, maxSize: 40)
        reportedOnLabel.adjustsFontForContentSizeCategory = true
        reportedOnLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 40)
        feedbackLabel.adjustsFontForContentSizeCategory = true
        feedbackLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 40)
        okBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        okBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 40)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
        self.refreshNavigationBarStyle()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        self.thankYouLabel.accessibilityIdentifier = "lbl_thank_you"
        self.thankYouInfoLabel.accessibilityIdentifier = "lbl_thank_you_info"
        self.categoryTitleLabel.accessibilityIdentifier = "lbl_category_title"
        self.categoryLabel.accessibilityIdentifier = "lbl_category"
        self.uniqueIdTitleLabel.accessibilityIdentifier = "lbl_uniqueid_title"
        self.uniqueIdLabel.accessibilityIdentifier = "lbl_uniqueid"
        self.reportedOnTitleLabel.accessibilityIdentifier = "lbl_reportedon_title"
        self.reportedOnLabel.accessibilityIdentifier = "lbl_reportedon"
        self.feedbackLabel.accessibilityIdentifier = "lbl_feedback"
        self.okBtn.accessibilityIdentifier = "btn_ok"
    }

    private func setupAccessibility(){
        self.navigationItem.leftBarButtonItem?.accessibilityTraits = .button
        navigationItem.leftBarButtonItem?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationItem.leftBarButtonItem?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.thankYouLabel.accessibilityTraits = .header
        self.thankYouLabel.accessibilityLabel = self.thankYouLabel.text
        self.thankYouLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.thankYouInfoLabel.accessibilityTraits = .staticText
        self.thankYouInfoLabel.accessibilityLabel = self.thankYouInfoLabel.text
        self.thankYouInfoLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.categoryTitleLabel.accessibilityTraits = .header
        self.categoryTitleLabel.accessibilityLabel = self.categoryTitleLabel.text
        self.categoryTitleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.categoryLabel.accessibilityTraits = .staticText
        self.categoryLabel.accessibilityLabel = self.categoryLabel.text
        self.categoryLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.uniqueIdTitleLabel.accessibilityTraits = .header
        self.uniqueIdTitleLabel.accessibilityLabel = self.uniqueIdTitleLabel.text
        self.uniqueIdTitleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.uniqueIdLabel.accessibilityTraits = .staticText
        self.uniqueIdLabel.accessibilityLabel = self.uniqueIdLabel.text
        self.uniqueIdLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.reportedOnTitleLabel.accessibilityTraits = .header
        self.reportedOnTitleLabel.accessibilityLabel = self.reportedOnTitleLabel.text
        self.reportedOnTitleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.reportedOnLabel.accessibilityTraits = .staticText
        self.reportedOnLabel.accessibilityLabel = self.reportedOnLabel.text
        self.reportedOnLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            
        self.feedbackLabel.accessibilityTraits = .staticText
        self.feedbackLabel.accessibilityLabel = self.feedbackLabel.text
        self.feedbackLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        okBtn.accessibilityTraits = .button
        okBtn.accessibilityLabel = LocalizationKeys.SCDefectReporterFormSubmissionVC.dr004OkButton.localized()
        okBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        

    }

    @IBAction func okBtnWasPressed(_ sender: UIButton) {
        // Go back to the Service Detail ViewController
        self.presenter.okBtnWasPressed()
    }
}
