//
//  SCForceUpdateVersionViewController.swift
//  OSCA
//
//  Created by A118572539 on 04/02/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCForceUpdateVersionViewController: UIViewController {
    
    @IBOutlet weak var titleLabel : UILabel!
    
    @IBOutlet weak var subtitlelabel : UILabel!
    
    @IBOutlet weak var updateButton: SCCustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        setupAccessibility()
    }
    
    private func setupUI() {
        self.updateButton.customizeBlueStyle()
        self.updateButton.setTitle("h_001_update_app".localized(), for: .normal)
        self.updateButton.titleLabel?.adaptFontSize()
        
        self.titleLabel.text = "h_001_update_required".localized()
        self.subtitlelabel.text = "h_001_update_detail_text".localized()
    }
    
    private func setupAccessibility() {
        self.updateButton.accessibilityIdentifier = "btn_update"
        self.updateButton.accessibilityTraits = .button
        self.updateButton.accessibilityLabel = "h_001_update_app".localized()
        self.updateButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.titleLabel.accessibilityIdentifier = "lbl_update_required"
        self.titleLabel.accessibilityTraits = .staticText
        self.titleLabel.accessibilityLabel = "h_001_update_required".localized()
        self.titleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.subtitlelabel.accessibilityIdentifier = "lbl_update_details"
        self.subtitlelabel.accessibilityTraits = .staticText
        self.subtitlelabel.accessibilityLabel = "h_001_update_detail_text".localized()
        self.subtitlelabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    @IBAction func updateApp(_ sender: UIButton) {
        if let url = URL(string: "https://apps.apple.com/de/app/citykey/id1516529784"),
           UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
