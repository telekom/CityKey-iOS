/*
Created by Harshada Deshmukh on 26/02/21.
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

class SCBasicPOIGuideCategorySelectionTableVC: UITableViewController {
            
    weak var delegate : SCBasicPOIGuideCategorySelectionTableVCDelegate?

    private var markForCategoryName : String?
    private var markColor : UIColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
    private var activityCategoryName : String?

    var poiCategoryList: [SCModelPOICategoryList]? = []
    var categoryItems: [POICategoryInfo]?
    var poiItems: [POIInfo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.estimatedRowHeight = GlobalConstants.kPOIGuideCellRegularHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = GlobalConstants.kPOIGuideCellRegularHeight
        tableView.sectionHeaderHeight = UITableView.automaticDimension
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    private func setupAccessibility(){
        self.view.accessibilityViewIsModal = true
    }
        
    func showPOICategoryMarker(for categoryName : String, color: UIColor?) {
        if let markColor = color {
            self.markColor = markColor
        }
        
        self.markForCategoryName = categoryName
        
        self.tableView.reloadData()
    }
    
    func showPOICategoryActivityIndicator(for categoryName : String) {
        self.activityCategoryName = categoryName
        self.markForCategoryName = nil
        self.tableView.reloadData()
    }

    func hidePOICategoryActivityIndicator() {
        self.activityCategoryName = nil
        self.markForCategoryName = nil
        self.tableView.reloadData()
    }
    
    private func isCategoryMarked(categoryName: String) -> Bool {
        return self.markForCategoryName?.lowercased() == categoryName.lowercased()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.categoryItems?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.poiCategoryList = self.categoryItems?[section].categoryList ?? []
        return self.poiCategoryList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let tableView = view as? UITableViewHeaderFooterView else { return }
        tableView.textLabel?.textColor = UIColor.red
     }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = self.categoryItems?[section].categoryGroupName
        let icon = self.categoryItems?[section].categoryGroupIcon

        let view = UIView()
        let label = UILabel()
        label.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18.0, maxSize: 30.0)
        label.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.numberOfLines = 0

        let imageView = UIImageView()
//        imageView.load(from: icon)
        imageView.image = SCUserDefaultsHelper.setupCategoryIcon(icon?.absoluteUrlString() ?? "").maskWithColor(color: kColor_cityColor)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        view.addSubview(label)
        
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        imageView.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 12).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 4).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4).isActive = true

        view.layoutIfNeeded()

        // set the header elements (Level1, like Kinder, Kultur, Freizeit) to
        label.accessibilityElementsHidden = true
        imageView.accessibilityElementsHidden = true

        view.isAccessibilityElement = true
        view.accessibilityElementsHidden = false
        view.accessibilityLabel = title
        view.accessibilityTraits = .header
        return view
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SCBasicPOIGuideCategoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SCBasicPOIGuideCategoryTableViewCell", for: indexPath) as! SCBasicPOIGuideCategoryTableViewCell
        
        self.poiCategoryList = self.categoryItems?[indexPath.section].categoryList ?? []

        cell.categoryLabel.text = self.poiCategoryList?[indexPath.row].categoryName ?? ""

        let categoryName = self.poiCategoryList?[indexPath.row].categoryName
        cell.categoryLabel.text = categoryName
        cell.categoryLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18.0, maxSize: 30.0)
        cell.categoryLabel.accessibilityIdentifier = categoryName

        if isCategoryMarked(categoryName: categoryName ?? "") {
            cell.backgroundColor = UIColor(named: "CLR_LISTITEM_ACTIVE")
            cell.checkmarkIcon.isHidden = false
            cell.accessibilityHint = "accessibility_hint_state_selected".localized()
        }else{
            cell.accessibilityHint = LocalizationKeys.SCBasicPOIGuideCategorySelectionTableVC.accessibilityCellDblClickHint.localized()
            cell.checkmarkIcon.isHidden = true
        }
        
        // set accessibilty information
        cell.categoryLabel.accessibilityElementsHidden = true
        cell.checkmarkIcon.accessibilityElementsHidden = true

        // and the detail elements under the header (Level2)
        cell.accessibilityTraits = .staticText
        cell.isAccessibilityElement = true
        cell.accessibilityElementsHidden = false
        cell.accessibilityLabel = categoryName
        cell.accessibilityTraits = .button
        cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        if (activityCategoryName?.lowercased() == categoryName?.lowercased()) {
            cell.activityIndicatorView.startAnimating()
            cell.checkmarkIcon.isHidden = true
        } else {
            cell.activityIndicatorView.stopAnimating()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.poiCategoryList = self.categoryItems?[indexPath.section].categoryList ?? []
        let categoryItemKey = self.poiCategoryList?[indexPath.row]

        UserdefaultHelper().setSelectedPOICategory(poiCategory: categoryItemKey!)

        if let cell = tableView.cellForRow(at: indexPath) as? SCBasicPOIGuideCategoryTableViewCell {
            cell.checkmarkIcon.isHidden = true
            cell.activityIndicatorView.startAnimating()
            UIAccessibility.post(notification: .layoutChanged, argument: cell)
        }
        self.markForCategoryName = categoryItemKey?.categoryName ?? ""
        self.activityCategoryName = categoryItemKey?.categoryName ?? ""
        self.delegate?.categoryWasSelected(categoryName: categoryItemKey?.categoryName ?? "", categoryID: categoryItemKey?.categoryId ?? 0, categoryGroupIcon: self.categoryItems?[indexPath.section].categoryGroupIcon?.absoluteUrlString() ?? "")
    }

}
