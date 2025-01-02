//
//  SCBasicPOIGuideProtocol.swift
//  OSCA
//
//  Created by A106551118 on 07/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCBasicPOIGuideDisplaying: AnyObject, SCDisplaying {
    func setupUI()
    func dismiss()
    func dismissCategory()
    func updateAllPOICategoryItems(with categoryItems: [POICategoryInfo])
    func showPOICategoryActivityIndicator(for categoryName: String)
    func hidePOICategoryActivityIndicator()
    
    func showLocationFailedMessage(messageTitle: String, withMessage: String)
    func showPOICategoryMarker(for categoryName : String, color: UIColor)
    func showOverlayWithActivityIndicator()
    func showOverlayWithGeneralError()
    func hideOverlay()
}

protocol SCBasicPOIGuidePresenting: SCPresenting {
    func setDisplay(_ display: SCBasicPOIGuideDisplaying)
    func categoryWasSelected(categoryName: String, categoryID: Int, categoryGroupIcon: String)
    func closeButtonWasPressed()
    func didPressGeneralErrorRetryBtn()
}

/**
 *
 * Delegate protocol for the Category tableview controller.
 *
 */
protocol SCBasicPOIGuideCategorySelectionTableVCDelegate : NSObjectProtocol
{
    func categoryWasSelected(categoryName: String, categoryID : Int, categoryGroupIcon: String)
}


