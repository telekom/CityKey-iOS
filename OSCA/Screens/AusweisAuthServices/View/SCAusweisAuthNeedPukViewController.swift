//
//  SCAusweisAuthNeedPukViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 19/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit


protocol SCAusweisAuthNeedPukViewDisplay : SCDisplaying , AnyObject {

}

class SCAusweisAuthNeedPukViewController: UIViewController {

    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var btnSubmit: SCCustomButton!
    var presenter : SCAusweisAuthNeedPukPresenting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibilityIDs()
        setupAccessibility()
        
    }

    func setupUI() {
    
        btnSubmit.customizeAusweisBlueStyle()
        lblHeader.text = "egov_pukinfo_label".localized()
        lblInfo.text = "\("egov_pukinfo_info1".localized())\n\n\("egov_pukinfo_info2".localized())"
        btnSubmit.setTitle("egov_pukinfo_btn".localized(), for: .normal)
        
        
        lblHeader.adjustsFontForContentSizeCategory = true
        lblHeader.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16, maxSize: nil)
        
        lblInfo.adjustsFontForContentSizeCategory = true
        lblInfo.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: nil)
        
        btnSubmit.titleLabel?.adjustsFontForContentSizeCategory = true
        btnSubmit.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18.0, maxSize: nil)

    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        btnSubmit.accessibilityIdentifier = "btn_Submit"
        lblHeader.accessibilityIdentifier = "lbl_Header"
        lblInfo.accessibilityIdentifier = "lbl_Info"
    }

    private func setupAccessibility(){
        btnSubmit.accessibilityLabel = "egov_pukinfo_btn".localized()
        btnSubmit.accessibilityTraits = .button
        btnSubmit.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        lblHeader.accessibilityLabel = "egov_pukinfo_label".localized()
        lblHeader.accessibilityTraits = .staticText
        lblHeader.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        
        lblInfo.accessibilityLabel = "\("egov_pukinfo_info1".localized())\n\n\("egov_pukinfo_info2".localized())"
        lblInfo.accessibilityTraits = .staticText
        lblInfo.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
    }
    
    @IBAction func submitClicked(_ sender: Any) {
     
        presenter.onSubmitClick()
    }
}

extension SCAusweisAuthNeedPukViewController : SCAusweisAuthNeedPukViewDisplay {
    
    
}
