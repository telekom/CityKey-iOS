//
//  SCAusweisAuthInsertCardViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 01/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAusweisAuthInsertCardDisplay : SCDisplaying, AnyObject {

}

class SCAusweisAuthInsertCardViewController: UIViewController {
    var presenter : SCAusweisAuthInsertCardPresenting!
        
    @IBOutlet weak var lblHoldTheCard: UILabel!
    @IBOutlet weak var lblImageGuideLabel: UILabel!
    
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
        
        lblHoldTheCard.text = "egov_attach_card_info1".localized()
        lblImageGuideLabel.text = "egov_attach_card_info2".localized()
        
        lblHoldTheCard.adjustsFontForContentSizeCategory = true
        lblHoldTheCard.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        lblImageGuideLabel.adjustsFontForContentSizeCategory = true
        lblImageGuideLabel.font = UIFont.SystemFont.italic.forTextStyle(style: .body, size: 16.0, maxSize: nil)

    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){

        lblHoldTheCard.accessibilityIdentifier = "lbl_lHoldTheCard"
        lblImageGuideLabel.accessibilityIdentifier = "lbl_ImageGuideLabel"
    }

    private func setupAccessibility(){
        
        lblHoldTheCard.accessibilityLabel = "egov_attach_card_info1".localized()
        lblHoldTheCard.accessibilityTraits =  .staticText
        lblHoldTheCard.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        lblImageGuideLabel.accessibilityLabel = "egov_attach_card_info2".localized()
        lblImageGuideLabel.accessibilityTraits =  .staticText
        lblImageGuideLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
    }
}

extension SCAusweisAuthInsertCardViewController : SCAusweisAuthInsertCardDisplay {
    
    
}
