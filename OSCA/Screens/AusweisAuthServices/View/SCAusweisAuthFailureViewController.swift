//
//  SCAusweisAuthFailureViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 01/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit


protocol SCAusweisAuthFailureViewDisplay : SCDisplaying, AnyObject {
    
    func setRestartWorkflowInProgress(inProgress :Bool)
    func showErrorMessage(errorMessage: String?, errorDescription: String?)
}

class SCAusweisAuthFailureViewController: UIViewController {
        
    @IBOutlet weak var lblFailureHeader: UILabel!
    @IBOutlet weak var lblFailureDescription: UILabel!
    @IBOutlet weak var btnStartAgain: SCCustomButton!

    var presenter : SCAusweisAuthFailurePresenting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("SCAusweisAuthFailureViewController : ViewDidLoad")
        setupUI()
        setupAccessibilityIDs()
        setupAccessibility()
        presenter.setDisplay(display: self)
        presenter.viewDidLoad()                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    func setupUI() {
       
        btnStartAgain.customizeAusweisBlueStyle()
        lblFailureHeader.text = "egov_error_label".localized()
        lblFailureDescription.text = "egov_error_info".localized()
        btnStartAgain.setTitle("egov_error_btn".localized(), for: .normal)
        
        lblFailureHeader.adjustsFontForContentSizeCategory = true
        lblFailureHeader.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        lblFailureDescription.adjustsFontForContentSizeCategory = true
        lblFailureDescription.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        btnStartAgain.titleLabel?.adjustsFontForContentSizeCategory = true
        btnStartAgain.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18.0, maxSize: nil)
        
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        lblFailureHeader.accessibilityIdentifier = "lbl_FailureHeader"
        lblFailureDescription.accessibilityIdentifier = "lbl_FailureDescription"
        btnStartAgain.accessibilityIdentifier = "btn_StartAgain"
    }

    private func setupAccessibility(){
        lblFailureHeader.accessibilityTraits = .staticText
        lblFailureHeader.accessibilityLabel = "egov_error_label".localized()
        lblFailureHeader.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        lblFailureDescription.accessibilityLabel = "egov_error_info".localized()
        lblFailureDescription.accessibilityTraits = .staticText
        lblFailureDescription.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        btnStartAgain.accessibilityLabel = "egov_error_btn".localized()
        btnStartAgain.accessibilityTraits = .button
        btnStartAgain.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    @IBAction func tryAgainClicked(_ sender : UIButton) {
        
        presenter.onTryAgain()        
    }
}

extension SCAusweisAuthFailureViewController : SCAusweisAuthFailureViewDisplay {
    
    func setRestartWorkflowInProgress(inProgress :Bool) {
        
        self.btnStartAgain.btnState = inProgress ? .progress : .normal
    }
 
    func showErrorMessage(errorMessage: String?, errorDescription: String?) {
        
        lblFailureHeader.text = errorDescription ?? "egov_error_label".localized()
        lblFailureDescription.text = errorMessage ?? "egov_error_info".localized()
    }
}
