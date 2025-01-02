//
//  SCDefectReporterCategoryProtocol.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCDefectReporterCategorySelectionViewDisplay : AnyObject, SCDisplaying {
    func reloadCategoryList(_ categoryList : [SCModelDefectCategory])
    func setNavigation(title : String)
    func push(viewController : UIViewController)
    func present(viewController: UIViewController)
}

protocol SCDefectReporterCategorySelectionPresenting : SCPresenting {
    func setDisplay(_ display : SCDefectReporterCategorySelectionViewDisplay)
    func didSelectCategory(_ category : SCModelDefectCategory)
    var serviceFlow: Services { get set }
}
