//
//  DeleteAccountViewController.swift
//  SmartCity
//
//  Created by Alexander Lichius on 08.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCDeleteAccountDisplaying {
    func push(viewController: UIViewController)
    func setupNavTitle(with title: String)
    func setupTitleLabel(with title: String)
    func setupDescriptionLabel(with text: String)
    func setupDeleteAccountButton(with title: String)
    func dismiss(completion: (() -> Void)?)

}

class SCDeleteAccountViewController: UIViewController {
    
    @IBOutlet weak var deleteAccountButton: SCCustomButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: SCTopAlignLabel!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    

    var presenter: SCDeleteAccountPresenting!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        setupDynamicFont()
    }
    
    private func setupDynamicFont() {
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: nil)
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: nil)
        deleteAccountButton.titleLabel?.adjustsFontForContentSizeCategory = true
        deleteAccountButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.deleteAccountButton.accessibilityIdentifier = "btn_delete_account"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.descriptionLabel.accessibilityIdentifier = "lbl_description"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func DeleteAccountButtonWasPressed(_ sender: Any) {
        self.presenter.deleteAccountButtonWasPressed()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
}
