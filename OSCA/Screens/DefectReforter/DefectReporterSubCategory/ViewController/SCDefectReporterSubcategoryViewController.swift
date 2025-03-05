/*
Created by Harshada Deshmukh on 06/05/21.
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

class SCDefectReporterSubcategoryViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    var presenter : SCDefectReporterSubCategoryPresenting!
    var subCategoryList : [SCModelDefectSubCategory]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter.setDisplay(self)
        tableView.dataSource = self
        tableView.delegate = self
        presenter.viewDidLoad()
        
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        handleDynamicTypeChange()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDynamicTypeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"

    }

    private func setupAccessibility(){
        self.navigationItem.backButtonTitle?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
}

extension SCDefectReporterSubcategoryViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCategoryList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SCDefectReporterCategoryCell", for: indexPath) as! SCDefectReporterCategoryCell
        cell.titleLabel.text = subCategoryList?[indexPath.row].serviceName
        let accItemString = String(format:LocalizationKeys.SCNewsOverviewTableViewController.AccessibilityTableSelectedCell.localized().replaceStringFormatter(), String(indexPath.row + 1), String(self.subCategoryList?.count ?? 0))
        cell.accessibilityTraits = .button
        cell.accessibilityHint = LocalizationKeys.SCNewsOverviewTableViewController.AccessibilityCellDblClickHint.localized()
        cell.accessibilityLabel = accItemString + ", " + cell.titleLabel.text!
        cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        cell.isAccessibilityElement = true
        cell.titleLabel.adjustsFontForContentSizeCategory = true
        cell.titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 16, maxSize: nil)
        
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let subCategory = subCategoryList?[indexPath.row] {
            SCUserDefaultsHelper.setDefectLocationStatus(status: false)
            presenter.didSelectSubCategory(subCategory)
        }
    }
}

extension SCDefectReporterSubcategoryViewController : SCDefectReporterSubCategoryViewDisplay {
    
    func reloadSubCategoryList(_ subCategoryList: [SCModelDefectSubCategory]) {
        self.subCategoryList = subCategoryList
        tableView.reloadData()
    }

    func setNavigation(title : String) {
        navigationItem.title = title
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func present(viewController: UIViewController) {
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        self.present(viewController, animated: true)
    }
}

