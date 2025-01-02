//
//  SCAusweisAuthProviderInfoViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 16/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAusweisAuthProviderInfoDisplay : SCDisplaying, AnyObject {
    
    func setProvider(_ provider : String)
    func setProviderLink(_ link : String)
    func setIssuer(_ issuer : String)
    func setIssuerLink(_ link : String)
    func setProviderInfo(_ info : String)
    func setValidity(_ validity : String)
    
}

class SCAusweisAuthProviderInfoViewController: UIViewController {

    var presenter : SCAusweisAuthProviderInfoPresenting!

    @IBOutlet weak var providerTitleLabel : UILabel!
    @IBOutlet weak var providerValueLabel : UILabel!
    @IBOutlet weak var providerLinkButton : UIButton!

    @IBOutlet weak var issuerTitleLabel : UILabel!
    @IBOutlet weak var issuerValueLabel : UILabel!
    @IBOutlet weak var issuerLinkButton : UIButton!

    @IBOutlet weak var providerInfoTitleLabel : UILabel!
    @IBOutlet weak var providerInfoValueTextView : UITextView!
    
    @IBOutlet weak var validityTitleLabel : UILabel!
    @IBOutlet weak var validityValueLabel : UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.presenter.setDisplay(display: self)
        self.presenter.viewDidLoad()
    }

    func setupUI() {
        
        providerTitleLabel.text = "egov_certificate_provider".localized()
        issuerTitleLabel.text = "egov_certificate_issuer".localized()
        providerInfoTitleLabel.text = "egov_certificate_providerinfo".localized()
        validityTitleLabel.text = "egov_certificate_validity".localized()
        
        
        providerTitleLabel.adjustsFontForContentSizeCategory = true
        providerTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        providerValueLabel.adjustsFontForContentSizeCategory = true
        providerValueLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        providerLinkButton.titleLabel?.adjustsFontForContentSizeCategory = true
        providerLinkButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        providerLinkButton.titleLabel?.numberOfLines = 0
        providerLinkButton.titleLabel?.lineBreakMode = .byCharWrapping
        
        issuerTitleLabel.adjustsFontForContentSizeCategory = true
        issuerTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        issuerValueLabel.adjustsFontForContentSizeCategory = true
        issuerValueLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        issuerLinkButton.titleLabel?.adjustsFontForContentSizeCategory = true
        issuerLinkButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        issuerLinkButton.titleLabel?.numberOfLines = 0
        issuerLinkButton.titleLabel?.lineBreakMode = .byCharWrapping
        
        providerInfoTitleLabel.adjustsFontForContentSizeCategory = true
        providerInfoTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        providerInfoValueTextView.adjustsFontForContentSizeCategory = true
        providerInfoValueTextView.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        validityTitleLabel.adjustsFontForContentSizeCategory = true
        validityTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        validityValueLabel.adjustsFontForContentSizeCategory = true
        validityValueLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

    }
    
    @IBAction func providerLinkClicked(_ sender: Any) {
        presenter.onProviderLinkClicked()
    }
    
    @IBAction func issuerLinkClicked(_ sender: Any) {
        presenter.onIssuerLinkClicked()
    }
    
}

extension SCAusweisAuthProviderInfoViewController : SCAusweisAuthProviderInfoDisplay {
    
    func setProvider(_ provider : String){
        self.providerValueLabel.text = provider
    }
    
    func setProviderLink(_ link : String) {
        self.providerLinkButton.setTitle(link, for: .normal)
    }
    
    func setIssuer(_ issuer : String) {
        self.issuerValueLabel.text = issuer
    }
    
    func setIssuerLink(_ link : String) {
        self.issuerLinkButton.setTitle(link, for: .normal)
    }
    
    func setProviderInfo(_ info : String) {
        self.providerInfoValueTextView.text = info
    }
    
    func setValidity(_ validity : String) {
        self.validityValueLabel.text = validity
    }

}
