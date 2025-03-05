/*
Created by Harshada Deshmukh on 09/03/21.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCBasicPOIGuideCategorySelectionVC: UIViewController {
    
    public var presenter: SCBasicPOIGuidePresenting!
        
    var categoryTableViewController : SCBasicPOIGuideCategorySelectionTableVC?
    var completionAfterDismiss: (() -> Void)? = nil
    
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shouldNavBarTransparent = false
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
    
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        registerForNotification()
    }

    private func registerForNotification() {
        SCDataUIEvents.registerNotifications(for: self,
                                             on: UIContentSizeCategory.didChangeNotification,
                                             with: #selector(handleDynamicTypeChange))
    }

    @objc private func handleDynamicTypeChange() {
        categoryTableViewController?.tableView.reloadData()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.retryButton.accessibilityIdentifier = "btn_retry_error"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = LocalizationKeys.SCBasicPOIGuideCategorySelectionVC.poi002CloseButtonContentDescription.localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.retryButton.accessibilityTraits = .button
        self.retryButton.accessibilityLabel = LocalizationKeys.SCBasicPOIGuideCategorySelectionVC.poi001RetryButtonDecription.localized()
        self.retryButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.navigationItem.backButtonTitle?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
//        self.navigationItem.titleView?.accessibilityLabel = self.navigationItem.title
//        self.navigationItem.titleView?.accessibilityTraits = .staticText
//        self.navigationItem.titleView?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
        self.refreshNavigationBarStyle()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismiss()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let categoryTableViewController as SCBasicPOIGuideCategorySelectionTableVC:
            categoryTableViewController.delegate = self
            self.categoryTableViewController = categoryTableViewController
            break
        default:
            break
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction func closeBtnWasPressed(_ sender: UIButton) {
        self.presenter.closeButtonWasPressed()
    }
    
    @IBAction func retryBtnWasPressed(_ sender: Any) {
        self.presenter.didPressGeneralErrorRetryBtn()
    }
}

// MARK: - SCBasicPOIGuideCategorySelectionTableVCDelegate
extension SCBasicPOIGuideCategorySelectionVC : SCBasicPOIGuideCategorySelectionTableVCDelegate {

    func categoryWasSelected(categoryName: String, categoryID : Int, categoryGroupIcon: String){
        self.presenter.categoryWasSelected(categoryName: categoryName, categoryID: categoryID, categoryGroupIcon: categoryGroupIcon)
    }
    
}
