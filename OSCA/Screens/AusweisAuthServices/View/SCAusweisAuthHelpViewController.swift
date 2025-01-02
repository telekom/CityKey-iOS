//
//  SCAusweisHelpViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 16/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAusweisAuthHelpViewDisplay : SCDisplaying, AnyObject {
    
}

class SCAusweisAuthHelpViewController: UIViewController {
    
    var presenter : SCAusweisAuthHelpPresenting!
    
    @IBOutlet weak var q1TitleLabel : UILabel!
    @IBOutlet weak var q1InfoLabel : UILabel!
    @IBOutlet weak var q1LinkButton : UIButton!

    @IBOutlet weak var q2TitleLabel : UILabel!
    @IBOutlet weak var q2InfoLabel : UILabel!

    @IBOutlet weak var q3TitleLabel : UILabel!
    @IBOutlet weak var q3InfoLabel : UILabel!
    @IBOutlet weak var q3LinkButton : UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.presenter.setDisplay(display: self)
        self.presenter.viewDidLoad()
    }
    
    func setupUI() {
        
        q1TitleLabel.text = "egov_help_label1".localized()
        q1InfoLabel.text = "egov_help_info1".localized()
        q1LinkButton.setTitle("egov_help_ausweissapp_link".localized(), for: .normal)
        q1LinkButton.tintColor = UIColor.clear

        q2TitleLabel.text = "egov_help_label2".localized()
        q2InfoLabel.text = "egov_help_info2".localized()
        
        q3TitleLabel.text = "egov_help_label3".localized()
        q3InfoLabel.text = "egov_help_info3".localized()
        q3LinkButton.setTitle("egov_help_aussweissapp_help_link".localized(), for: .normal)
        q3LinkButton.tintColor = UIColor.clear
        
        q1TitleLabel.adjustsFontForContentSizeCategory = true
        q1TitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        q1InfoLabel.adjustsFontForContentSizeCategory = true
        q1InfoLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        
        q1LinkButton.titleLabel?.adjustsFontForContentSizeCategory = true
        q1LinkButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 30.0)
        q1LinkButton.titleLabel?.numberOfLines = 0
        q1LinkButton.titleLabel?.lineBreakMode = .byWordWrapping
        
        q2TitleLabel.adjustsFontForContentSizeCategory = true
        q2TitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        q2InfoLabel.adjustsFontForContentSizeCategory = true
        q2InfoLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        
        q3TitleLabel.adjustsFontForContentSizeCategory = true
        q3TitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        q3InfoLabel.adjustsFontForContentSizeCategory = true
        q3InfoLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        
        q3LinkButton.titleLabel?.adjustsFontForContentSizeCategory = true
        q3LinkButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 30.0)
        q3LinkButton.titleLabel?.numberOfLines = 0
        q3LinkButton.titleLabel?.lineBreakMode = .byWordWrapping

    }
    
    func setupAccessibilityIDs() {
        
    }
    
    func setupAccessibility() {
        
        
    }
    
    @IBAction func downloadAusweisAppClicked(_ sender: Any) {
    
        self.presenter.onDownloadAusweisAppClick()
    }
    
    @IBAction func callAusweisAppHelpClicked(_ sender: Any) {
        
        self.presenter.onCallAusweisHelpClick()
    }
}

extension SCAusweisAuthHelpViewController : SCAusweisAuthHelpViewDisplay {
    
    
}
