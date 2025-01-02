//
//  SCDefectReporterSubcategoryViewController.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 06/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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

