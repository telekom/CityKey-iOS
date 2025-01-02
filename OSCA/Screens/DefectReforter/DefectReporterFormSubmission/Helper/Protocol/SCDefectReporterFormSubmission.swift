//
//  SCDefectReporterFormSubmissionProtocol.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCDefectReporterFormSubmissionViewDisplay : AnyObject, SCDisplaying {
    func setNavigation(title : String)
    func setupUI(category: SCModelDefectCategory, subCategory: SCModelDefectSubCategory?, uniqueId: String)
    func dismiss(completion: (() -> Void)?)

}

protocol SCDefectReporterFormSubmissionPresenting: SCPresenting {
    func setDisplay(_ display: SCDefectReporterFormSubmissionViewDisplay)
    func okBtnWasPressed()
    func getCityName() -> String?
    func getCityId() -> Int
    func showFeedbackLabel() -> Bool
    func getServiceFlow() -> Services
}
