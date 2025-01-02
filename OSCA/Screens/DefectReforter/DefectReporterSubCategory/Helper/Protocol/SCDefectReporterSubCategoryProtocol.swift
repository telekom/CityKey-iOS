//
//  SCDefectReporterSubCategoryProtocol.swift
//  OSCA
//
//  Created by Bhaskar N S on 25/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCDefectReporterSubCategoryViewDisplay : AnyObject, SCDisplaying {
    
    func reloadSubCategoryList(_ subCategoryList : [SCModelDefectSubCategory])
    func setNavigation(title : String)
    func push(viewController : UIViewController)
    func present(viewController: UIViewController)

}

protocol SCDefectReporterSubCategoryPresenting : SCPresenting {
    func setDisplay(_ display : SCDefectReporterSubCategoryViewDisplay)
    func didSelectSubCategory(_ category : SCModelDefectSubCategory)
    var serviceFlow: Services { get set }
}
