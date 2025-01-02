//
//  SCAusweisAuthNeedCanViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 18/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAusweisAuthNeedCanViewDisplay : SCDisplaying , AnyObject {

}

class SCAusweisAuthNeedCanViewController: UIViewController {

    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var btnSubmit: SCCustomButton!
    var presenter : SCAusweisAuthNeedCanPresenting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibilityIDs()
        setupAccessibility()        
    }

    func setupUI() {
    
        btnSubmit.customizeAusweisBlueStyle()
        lblHeader.text = "egov_caninfo_label".localized()
        lblInfo.text = "\("egov_caninfo_info1".localized())\n\n\("egov_caninfo_info2".localized())"
        btnSubmit.setTitle("egov_caninfo_btn".localized(), for: .normal)
        
        
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        btnSubmit.accessibilityIdentifier = "btn_Submit"
        lblHeader.accessibilityIdentifier = "lbl_Header"
        lblInfo.accessibilityIdentifier = "lbl_Info"
        
        lblHeader.adjustsFontForContentSizeCategory = true
        lblHeader.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16, maxSize: nil)
        
        lblInfo.adjustsFontForContentSizeCategory = true
        lblInfo.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: nil)
        
        btnSubmit.titleLabel?.adjustsFontForContentSizeCategory = true
        btnSubmit.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18.0, maxSize: nil)
        
    }

    private func setupAccessibility(){
        btnSubmit.accessibilityLabel = "egov_caninfo_btn".localized()
        btnSubmit.accessibilityTraits = .button
        btnSubmit.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        lblHeader.accessibilityLabel = "egov_caninfo_label".localized()
        lblHeader.accessibilityTraits = .staticText
        lblHeader.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        
        lblInfo.accessibilityLabel = "\("egov_caninfo_info1".localized())\n\n\("egov_caninfo_info2".localized())"
        lblInfo.accessibilityTraits = .staticText
        lblInfo.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
    }
    
    @IBAction func submitClicked(_ sender: Any) {
     
        presenter.onSubmitClick()
    }
}

extension SCAusweisAuthNeedCanViewController : SCAusweisAuthNeedCanViewDisplay {
    
    
}
