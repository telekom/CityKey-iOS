//
//  SCEditPersonalDataOverviewTVCTableViewController.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 15/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCEditPersonalDataOverviewTVCTableViewController: UITableViewController {

    public var presenter: SCEditPersonalDataOverviewPresenting!

    @IBOutlet weak var dateOfBirthChangeTopLbl: UILabel!
    @IBOutlet weak var dateOfBirthChangeTxtField: UITextField!
    @IBOutlet weak var residenceChangeTopLbl: UILabel!
    @IBOutlet weak var residenceChangeTxtField: UITextField!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()

    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.dateOfBirthChangeTopLbl.accessibilityIdentifier = "lbl_date_of_birth_change"
        self.dateOfBirthChangeTxtField.accessibilityIdentifier = "txtfld_date_of_birth_change"
        self.residenceChangeTopLbl.accessibilityIdentifier = "lbl_change_residence"
        self.residenceChangeTxtField.accessibilityIdentifier = "txtfld_change_residence"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        // Dynamic font
        dateOfBirthChangeTopLbl.adjustsFontForContentSizeCategory = true
        dateOfBirthChangeTopLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 25)
        dateOfBirthChangeTxtField.adjustsFontForContentSizeCategory = true
        dateOfBirthChangeTxtField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 22)
        
        residenceChangeTopLbl.adjustsFontForContentSizeCategory = true
        residenceChangeTopLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 25)
        residenceChangeTxtField.adjustsFontForContentSizeCategory = true
        residenceChangeTxtField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 22)
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//
//        if #available(iOS 13.0, *) {
//            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//                if let image = self.lockButton?.image(for: .normal){
//                    self.lockButton?.setImage(image.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
//                }
//            }
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presenter.viewWillAppear()
        
    }

    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
            
        case 0:
            self.presenter.editDateOfBirthWasPressed()
            break
        case 1:
            self.presenter.editResidenceWasPressed()
            break
        default:
            self.presenter.editDateOfBirthWasPressed()
            break
        }
    }

}

extension SCEditPersonalDataOverviewTVCTableViewController: SCEditPersonalDataOverviewDisplaying {
    
    func setupNavigationBar(title: String){
        self.navigationItem.title = title
        self.navigationItem.backButtonTitle = ""
    }
    
    func setupUI(postcode : String, profile: SCModelProfile){
        self.dateOfBirthChangeTopLbl.text = "p_002_profile_personal_settings_label_Dob".localized()
        self.residenceChangeTopLbl.text = "p_002_profile_personal_settings_label_Residence".localized()
        self.dateOfBirthChangeTxtField.placeholder = "p_002_profile_personal_settings_label_Dob".localized()
        self.residenceChangeTxtField.placeholder = "p_002_profile_personal_settings_label_Residence".localized()
        
        var dobText = ""
        if let birthdate = profile.birthdate {
            dobText = birthdayStringFromDate(birthdate: birthdate)
        } else {
            dobText = "p_001_profile_no_date_of_birth_added".localized()
        }
                
        self.dateOfBirthChangeTxtField.text = dobText
        let residenceName = profile.postalCode + " " + profile.cityName
        self.residenceChangeTxtField.text = residenceName
    }

    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }

}
