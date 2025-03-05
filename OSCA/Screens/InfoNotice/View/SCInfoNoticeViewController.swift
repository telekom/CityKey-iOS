/*
Created by Michael on 01.02.20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import WebKit

class SCInfoNoticeViewController: UIViewController {

    public var presenter: SCInfoNoticePresenting!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var topTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.shouldNavBarTransparent = false
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "nvitem_btn_right"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeBtnWasPressed()
    }

    private func set(title: String) {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        titleLabel.text = title
        titleLabel.numberOfLines = 2
        titleLabel.textColor = UIColor(named: "CLR_NAVBAR_SOLID_TITLE")
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }
}

extension SCInfoNoticeViewController: SCInfoNoticeDisplaying {
    
    func setupUI(title: String, topText: NSAttributedString, displayActIndicator: Bool) {
        set(title: title)
        self.navigationItem.backBarButtonItem?.title = ""
        
        if displayActIndicator{
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
            activityIndicator.backgroundColor = UIColor(named: "CLR_BCKGRND")
            if #available(iOS 13.0, *) {
                activityIndicator.style = .medium
            } else {
                activityIndicator.style = .gray
            }
            
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            
            DispatchQueue.main.async {
                self.topTextView.attributedText = topText
                self.topTextView.setNeedsLayout()
                self.topTextView.setNeedsUpdateConstraints()
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        } else {
            self.topTextView.attributedText = topText
            self.topTextView.setNeedsLayout()
            self.topTextView.setNeedsUpdateConstraints()
        }
        
        self.view.setNeedsLayout()
        self.stackView.invalidateIntrinsicContentSize()
    }
    
    func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
}
