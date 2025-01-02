//
//  SCCitizenSurveyDetailPresenting.swift
//  OSCA
//
//  Created by Bhaskar N S on 19/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCCitizenSurveyDetailDisplaying: AnyObject, SCDisplaying {
    func push(viewController: UIViewController)
    func showBtnActivityIndicator(_ show : Bool)
    func present(viewController: UIViewController)
}

protocol SCCitizenSurveyDetailViewDelegate {
    func acceptedDataPrivacy()
}

protocol SCCitizenSurveyDetailPresenting : SCPresenting{
    func set(display: SCCitizenSurveyDetailDisplaying)
    func getSurveyImage() -> SCImageURL?
    func getSurveyPresentableStartDate() -> String
    func getSurveyEndDatePlaceholder() -> String
    func getSurveyPresentableEndDate() -> String
    func getSurveyDaysLeftViewProgress() -> (Double, Int)
    func getSurveyTitle() -> String
    func getSurveyStatus() -> SCSurveyStatus
    func getSurveyIsPopular() -> Bool
    func getSurveyHeading() -> String
    func getSurveyDescription() -> NSAttributedString?
    func getShareButton() -> UIBarButtonItem
    func displaySurveyQuestionViewController()
    func displayDataPrivacyViewController(delegate: SCCitizenSurveyDetailViewDelegate)
}
