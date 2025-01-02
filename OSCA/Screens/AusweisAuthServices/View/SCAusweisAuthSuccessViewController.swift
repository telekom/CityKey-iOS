//
//  SCAusweisAuthSuccessViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 01/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAusweisAuthSuccessViewDisplay : SCDisplaying, AnyObject {
    
    
}

class SCAusweisAuthSuccessViewController: UIViewController {

    var presenter : SCAusweisAuthSuccessPresenter!
    
    @IBOutlet weak var lblSuccessText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        lblSuccessText.text = "egov_success_info".localized()
        
        lblSuccessText.adjustsFontForContentSizeCategory = true
        lblSuccessText.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: nil)
        
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){

        lblSuccessText.accessibilityIdentifier = "lbl_SuccessText"
    }

    private func setupAccessibility(){
        
        lblSuccessText.accessibilityLabel = "egov_success_info".localized()
        lblSuccessText.accessibilityTraits = .staticText
        lblSuccessText.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
}

extension SCAusweisAuthSuccessViewController : SCAusweisAuthSuccessViewDisplay {
    
    
}


