//
//  SCVersionInformationViewController.swift
//  OSCA
//
//  Created by Sahil Dadas on 20/10/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCVersionInformationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titletextview: UITextView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var okButton: SCCustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    private func setupUI() {
        self.titleLabel.text = LocalizationKeys.SCVersionInformationViewController.wn001WhatIsNewTitle.localized()
        self.titletextview.text = LocalizationKeys.SCVersionInformationViewController.wn002NewsWidgetTitle.localized()
        self.textView.text = LocalizationKeys.SCVersionInformationViewController.wn003NewsWidgetUpdateDescription.localized()
        self.okButton.setTitle(LocalizationKeys.SCVersionInformationViewController.wn004ContinueTitle.localized(), for: .normal)
        self.okButton.customizeBlueStyle()
        self.okButton.titleLabel?.adaptFontSize()
        
    }
    
    @IBAction func okButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
