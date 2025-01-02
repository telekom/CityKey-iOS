//
//  SCAusweisAuthLoadingViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 24/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAusweisAuthLoadingDisplay : SCDisplaying, AnyObject {
    
}

class SCAusweisAuthLoadingViewController: UIViewController {
    
    var presenter : SCAusweisAuthLoadingPresenting!
    @IBOutlet weak var lblLoadigText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAccessibilityIDs()
        setupAccessibility()
        presenter.setDisplay(display: self)
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.viewDidAppear()
    }
    
    func setupUI() {
        
        lblLoadigText.text = "egov_loading_info1".localized()
        
        lblLoadigText.adjustsFontForContentSizeCategory = true
        lblLoadigText.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
    }
    
    private func setupAccessibilityIDs(){

        lblLoadigText.accessibilityIdentifier = "lbl_LoadigText"
    }

    private func setupAccessibility(){

        lblLoadigText.accessibilityLabel = "egov_loading_info1".localized()
        lblLoadigText.accessibilityTraits = .staticText
        lblLoadigText.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
}

extension SCAusweisAuthLoadingViewController : SCAusweisAuthLoadingDisplay {
    
    
    
    
}
