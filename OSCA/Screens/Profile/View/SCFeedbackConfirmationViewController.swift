/*
Created by Ayush on 09/09/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Ayush
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCFeedbackConfirmationViewController: UIViewController {
   
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desclabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var submitButton: SCCustomButton!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    public var presenter: SCFeedbackConfirmationPresenting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.adaptFontSize()
        self.presenter.setDisplay(self)
        self.submitButton.customizeBlueStyle()
        self.presenter.viewDidLoad()
   }
    
    private func setupUI() {
        self.navigationItem.title = "p_001_feedback_title".localized()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(closeButtonTapped)), animated: false)
        self.submitButton.setTitle("feedback_ok_button".localized(), for: .normal)
        
        titleLabel.text = "feedback_successful_submission_heading".localized()
        desclabel.attributedText = "feedback_successful_submission_description".localized().applyHyphenation()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs() {
        self.submitButton.accessibilityIdentifier = "btn_ok"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.desclabel.accessibilityIdentifier = "lbl_desc"
        
    }
    
    private func setupAccessibility() {
        self.submitButton.accessibilityTraits = .button
        self.submitButton.accessibilityLabel = "send_button"
        self.submitButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    private func adaptFontSize() {
        titleLabel.adaptFontSize()
        desclabel.adaptFontSize()
        
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18, maxSize: nil)
        
        desclabel.adjustsFontForContentSizeCategory = true
        desclabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: nil)
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okButtontapped(_ sender: Any) {
        let viewControllers = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
}

extension SCFeedbackConfirmationViewController: SCFeedbackConfirmationDisplaying {
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setupUI(email : String){
        
    }

    func dismissView(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
    }

    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
}
