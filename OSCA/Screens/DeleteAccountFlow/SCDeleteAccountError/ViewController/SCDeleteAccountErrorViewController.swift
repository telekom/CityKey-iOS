//
//  SCDeleteAccountErrorViewController.swift
//  SmartCity
//
//  Created by Alexander Lichius on 15.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDeleteAccountErrorViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var okButton: SCCustomButton!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    var presenter: SCDeleteAccountErrorPresenting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()

    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.titleLabel.accessibilityIdentifier = "lbl_error_title"
        self.subtitleLabel.accessibilityIdentifier = "lbl_error_subtitle"
        self.okButton.accessibilityIdentifier = "btn_error_ok"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    @IBAction func okButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
    
}
