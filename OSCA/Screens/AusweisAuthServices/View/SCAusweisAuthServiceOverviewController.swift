//
//  AusweisAuthServiceOverviewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 24/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAusweisAuthServiceOverviewDisplay : SCDisplaying , AnyObject {

    func setProvider(provider : String)
    func setProviderDataRequiredInfo(dataRequired : String)
    func setPurposeInfo(purpose : String)
}

class SCAusweisAuthServiceOverviewController: UIViewController {

    @IBOutlet weak var enterPinButton : SCCustomButton!
    @IBOutlet weak var lblServiceInfo : UILabel!
    @IBOutlet weak var lblProviderTitle : UILabel!
    @IBOutlet weak var lblProviderTitleValue : UILabel!
    @IBOutlet weak var lblProviderDataRequiredTitle : UILabel!
    @IBOutlet weak var lblProviderDataRequiredValues : UILabel!
    @IBOutlet weak var lblDataUsageDescription : UILabel!
    @IBOutlet weak var lblPurposeTitle : UILabel!
    @IBOutlet weak var lblPurposeValue : UILabel!
    
    @IBOutlet weak var lblProviderTitleValueContainer : UIView!
    
    var presenter : SCAusweisAuthServiceOverviewPresenting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibilityIDs()
        setupAccessibility()
        presenter.setDisplay(display: self)
        presenter.viewDidLoad()
        
    }
    
    func setupUI() {
        
        enterPinButton.customizeAusweisBlueStyle()
        
        self.lblServiceInfo.text = "egov_info_provider_info".localized()
        self.lblProviderTitle.text = "egov_info_provider_label".localized()
        self.lblProviderDataRequiredTitle.text = "egov_info_read_data_label".localized()
        self.lblDataUsageDescription.text = "egov_info_read_data_info".localized()
        self.lblPurposeTitle.text = "egov_info_purpose_label".localized()
        self.enterPinButton.setTitle("egov_info_btn".localized(), for: .normal)

        self.lblServiceInfo.adjustsFontForContentSizeCategory = true
        self.lblServiceInfo.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        
        self.lblProviderTitle.adjustsFontForContentSizeCategory = true
        self.lblProviderTitle.font = UIFont.SystemFont.bold.forTextStyle(style: .headline, size: 17.0, maxSize: nil)

        self.lblProviderTitleValue.adjustsFontForContentSizeCategory = true
        self.lblProviderTitleValue.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        self.lblProviderDataRequiredTitle.adjustsFontForContentSizeCategory = true
        self.lblProviderDataRequiredTitle.font = UIFont.SystemFont.bold.forTextStyle(style: .headline, size: 17.0, maxSize: nil)

        self.lblProviderDataRequiredValues.adjustsFontForContentSizeCategory = true
        self.lblProviderDataRequiredValues.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        self.lblDataUsageDescription.adjustsFontForContentSizeCategory = true
        self.lblDataUsageDescription.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        
        self.lblPurposeTitle.adjustsFontForContentSizeCategory = true
        self.lblPurposeTitle.font = UIFont.SystemFont.bold.forTextStyle(style: .headline, size: 17.0, maxSize: nil)

        self.lblPurposeValue.adjustsFontForContentSizeCategory = true
        self.lblPurposeValue.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        
        self.enterPinButton.titleLabel?.adjustsFontForContentSizeCategory = true
        self.enterPinButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18.0, maxSize: nil)
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.viewDidAppear()
    }
    
    @IBAction func onClickEnterPin() {
        debugPrint("onClickEnterPin")
        presenter.onClickEnterPIN()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){

        self.lblServiceInfo.accessibilityIdentifier = "lbl_ServiceInfo"
        self.lblProviderDataRequiredTitle.accessibilityIdentifier = "lbl_ProviderDataRequiredTitle"
        self.lblProviderDataRequiredValues.accessibilityIdentifier = "lbl_ProviderDataRequiredValues"
        self.lblDataUsageDescription.accessibilityIdentifier = "lbl_DataUsageDescription"
        self.lblPurposeTitle.accessibilityIdentifier = "lbl_PurposeTitle"
        self.lblPurposeValue.accessibilityIdentifier = "lbl_PurposeValue"
        self.enterPinButton.accessibilityIdentifier = "btn_EnterPin"
        
        self.lblProviderTitleValueContainer.isAccessibilityElement = true
        self.lblProviderTitleValueContainer.accessibilityIdentifier = "lbl_ProviderTitleValueContainer"
        self.lblProviderTitle.isAccessibilityElement = false
        self.lblProviderTitleValue.isAccessibilityElement = false

        
    }

    private func setupAccessibility(){
        
        self.lblServiceInfo.accessibilityTraits = .staticText
        self.lblServiceInfo.accessibilityLabel = "egov_info_provider_info".localized()
        self.lblServiceInfo.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        self.lblProviderDataRequiredTitle.accessibilityTraits = .staticText
        self.lblProviderDataRequiredTitle.accessibilityLabel = "egov_info_read_data_label".localized()
        self.lblProviderDataRequiredTitle.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        self.lblProviderDataRequiredValues.accessibilityTraits = .staticText
        self.lblProviderDataRequiredValues.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.lblDataUsageDescription.accessibilityTraits = .staticText
        self.lblDataUsageDescription.accessibilityLabel = "egov_info_read_data_info".localized()
        self.lblDataUsageDescription.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.lblPurposeTitle.accessibilityTraits = .staticText
        self.lblPurposeTitle.accessibilityLabel = "egov_info_purpose_label".localized()
        self.lblPurposeTitle.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        self.lblPurposeValue.accessibilityTraits = .staticText
        self.lblPurposeValue.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        self.enterPinButton.accessibilityTraits = .button
        self.enterPinButton.accessibilityLabel = "egov_info_btn".localized()
        self.enterPinButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        
//        self.lblProviderTitle.accessibilityTraits = .staticText
//        self.lblProviderTitle.accessibilityLabel = "egov_info_provider_label".localized()
//        self.lblProviderTitle.accessibilityLanguage = SCUtilities.preferredContentLanguage()
//
//        self.lblProviderTitleValue.accessibilityTraits = .staticText
//        self.lblProviderTitleValue.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        self.lblProviderTitleValueContainer.accessibilityLabel = "egov_info_provider_label".localized()
        self.lblProviderTitleValueContainer.accessibilityTraits = .link
        self.lblProviderTitleValueContainer.accessibilityLanguage = SCUtilities.preferredContentLanguage()


        
    }
    
    @IBAction @objc func moreInfoTapped() {
        self.presenter.onMoreInfoClicked()
    }
}

extension SCAusweisAuthServiceOverviewController : SCAusweisAuthServiceOverviewDisplay {
    
    func setProvider(provider : String) {
     
        self.lblProviderTitleValue.text = provider
        self.lblProviderTitleValueContainer.accessibilityLabel = "\("egov_info_provider_label".localized())\n\(provider)"
    }
    
    func setProviderDataRequiredInfo(dataRequired : String) {
        
        self.lblProviderDataRequiredValues.text = dataRequired
    }
    
    func setPurposeInfo(purpose : String) {
        
        self.lblPurposeValue.text = purpose
        self.lblPurposeTitle.text = purpose.count == 0  ? "" : "egov_info_purpose_label".localized()
    }
    
}
