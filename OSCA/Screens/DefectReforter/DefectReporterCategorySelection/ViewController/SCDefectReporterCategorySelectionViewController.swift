//
//  SCDefectReporterCategorySelectionViewController.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 06/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDefectReporterCategorySelectionViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    var presenter : SCDefectReporterCategorySelectionPresenting!
    var categoryList : [SCModelDefectCategory]?
    
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
        navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"

    }

    private func setupAccessibility(){
        self.navigationItem.backButtonTitle?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
}
