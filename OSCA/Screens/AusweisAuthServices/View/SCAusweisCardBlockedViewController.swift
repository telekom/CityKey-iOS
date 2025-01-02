//
//  SCAusweisCardBlockedViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 24/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAusweisAuthCardBlockedViewDisplay : AnyObject {
    
}

class SCAusweisAuthCardBlockedViewController: UIViewController {

    var presenter : SCAusweisAuthCardBlockedPresenting!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var submitButton: SCCustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.presenter.setDisplay(display: self)
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        
         
    }
    
    func setupUI() {
        
        submitButton.customizeAusweisBlueStyle()
        lblHeader.text = "egov_cardblocked_label".localized()
        lblInfo.text = "\("egov_cardblocked_info1".localized())\n\n\("egov_cardblocked_info2".localized())"
        submitButton.setTitle("", for: .normal)
        
        
        lblHeader.adjustsFontForContentSizeCategory = true
        lblHeader.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        lblInfo.adjustsFontForContentSizeCategory = true
        lblInfo.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        
        submitButton.titleLabel?.adjustsFontForContentSizeCategory = true
        submitButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        submitButton.titleLabel?.numberOfLines = 0
        submitButton.titleLabel?.lineBreakMode = .byWordWrapping
    }
}

extension SCAusweisAuthCardBlockedViewController : SCAusweisAuthCardBlockedViewDisplay {
    
}
