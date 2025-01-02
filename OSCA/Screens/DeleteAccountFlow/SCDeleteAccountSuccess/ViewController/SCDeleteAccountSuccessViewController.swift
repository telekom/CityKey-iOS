//
//  SCDeleteAccountSuccessViewController.swift
//  SmartCity
//
//  Created by Alexander Lichius on 15.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDeleteAccountSuccessViewController: UIViewController {
    var presenter: SCDeleteAccountSuccessPresenting!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var okButton: SCCustomButton!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.titleImageView.accessibilityIdentifier = "img_title"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.subtitleLabel.accessibilityIdentifier = "lbl_subtitle"
        self.descriptionLabel.accessibilityIdentifier = "lbl_description"
        self.okButton.accessibilityIdentifier = "btn_ok"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }


    @IBAction func okButtonTapped(_ sender: Any) {
        self.presenter.okButtonTapped()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
}
