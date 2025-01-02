//
//  SCDefectReporterCategorySelectionViewController+TableView.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCDefectReporterCategorySelectionViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SCDefectReporterCategoryCell", for: indexPath) as! SCDefectReporterCategoryCell
        cell.titleLabel.text = categoryList?[indexPath.row].serviceName
        let accItemString = String(format:LocalizationKeys.SCNewsOverviewTableViewController.AccessibilityTableSelectedCell.localized().replaceStringFormatter(), String(indexPath.row + 1), String(self.categoryList?.count ?? 0))
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
        
        if let category = categoryList?[indexPath.row] {
            SCUserDefaultsHelper.setDefectLocationStatus(status: false)
            presenter.didSelectCategory(category)
        }
    }

}
