//
//  SCDefectReporterCategorySelectionViewController+Displaying.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCDefectReporterCategorySelectionViewController : SCDefectReporterCategorySelectionViewDisplay {
    
    func reloadCategoryList(_ categoryList: [SCModelDefectCategory]) {
        self.categoryList = categoryList
        tableView.reloadData()
    }

    func setNavigation(title : String) {
        self.navigationItem.title = title
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
