//
//  SCCitizenSurveyDetailPresenter.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 08/12/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCCitizenSurveyDetailPresenter{

    private weak var display: SCCitizenSurveyDetailDisplaying?
    private let injector: SCCitizenSurveyServiceInjecting & SCAdjustTrackingInjection
    private let survey: SCModelCitizenSurveyOverview
    private let serviceData: SCBaseComponentItem
    private let singleSurveyWorker: SCCitizenSingleSurveyWorking
    private let cityID: Int
    private let dataCache: SCDataCaching
    private let citizenSurveyWorker: SCCitizenSurveyWorking

    init(survey: SCModelCitizenSurveyOverview,
         serviceData: SCBaseComponentItem,
         singleSurveyWorker: SCCitizenSingleSurveyWorking,
         cityID: Int,
         injector: SCCitizenSurveyServiceInjecting & SCAdjustTrackingInjection,
         dataCache: SCDataCaching,
         citizenSurveyWorker: SCCitizenSurveyWorking = SCCitizenSurveyWorker(requestFactory: SCRequest())) {
        self.survey = survey
        self.serviceData = serviceData
        self.injector = injector
        self.singleSurveyWorker = singleSurveyWorker
        self.cityID = cityID
        self.dataCache = dataCache
        self.citizenSurveyWorker = citizenSurveyWorker
    }

    @objc private func share() {
        
    }
}

extension SCCitizenSurveyDetailPresenter: SCCitizenSurveyDetailPresenting {
    
    func set(display: SCCitizenSurveyDetailDisplaying) {
        self.display = display
    }

    func getSurveyImage() -> SCImageURL? {
        return serviceData.itemImageURL
    }

    func getSurveyPresentableStartDate() -> String {
        String(format: LocalizationKeys.SCCitizenSurveyDetailPresenter.cs003CreationDateFormat.localized().replaceStringFormatter(),
               stringFromDate(date: survey.startDate))
    }

    func getSurveyEndDatePlaceholder() -> String {
        return LocalizationKeys.SCCitizenSurveyDetailPresenter.cs003EndDateLabel.localized()
    }

    func getSurveyPresentableEndDate() -> String {
        return stringFromDate(date: survey.endDate)
    }

    func getSurveyDaysLeftViewProgress() -> (Double, Int) {
        return (survey.getDaysLeftProgress(), survey.daysLeft)
    }

    func getSurveyTitle() -> String {
        return survey.name
    }

    func getSurveyStatus() -> SCSurveyStatus {
        return survey.status
    }

    func getSurveyIsPopular() -> Bool {
        return survey.isPopular
    }

    func getSurveyHeading() -> String {
        return survey.name
    }

    func getSurveyDescription() -> NSAttributedString? {
        var surveyDescription = NSMutableAttributedString(attributedString: survey.description.htmlAttributedString ?? NSAttributedString(string: ""))
        surveyDescription.addAttributes([.foregroundColor: UIColor(named: "CLR_LABEL_TEXT_BLACK")!],
                                  range: NSRange(0..<surveyDescription.length))
        
        return surveyDescription
    }

    func getShareButton() -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "icon_share"),
                               style: .plain,
                               target: self,
                               action: #selector(share))
    }

    func displaySurveyQuestionViewController() {
        self.display?.showBtnActivityIndicator(true)
        
        self.singleSurveyWorker.getSurvey(for: survey.id, cityId: self.cityID, completion: {
            (surveyDetail, error) in
            self.display?.showBtnActivityIndicator(false)
            guard error == nil else {
                self.display?.showErrorDialog(error!, retryHandler:  { self.displaySurveyQuestionViewController()})
                return
            }

            surveyDetail?.surveyName = self.survey.name
            surveyDetail?.surveyId = self.survey.id

            self.display?.push(viewController: self.injector.getCitizenSurveyPageViewController(survey: surveyDetail!))
        })
    }

    func displayDataPrivacyViewController(delegate: SCCitizenSurveyDetailViewDelegate) {
        if dataCache.isDataPrivacyAccepted(for: survey.id, cityID: "\(cityID)") == true ||
            isPreviewMode {
            displaySurveyQuestionViewController()
        } else {
            display?.showBtnActivityIndicator(true)
            citizenSurveyWorker.fetchDataPrivacyNoticeForPolls(ciyId: "\(cityID)") { [weak self] dataPrivcyNotice, error in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.display?.showBtnActivityIndicator(false)
                strongSelf.showDataPrivacyViewController(dataPrivcyNotice: dataPrivcyNotice, error: error, delegate: delegate)
            }
        }
    }

    private func showDataPrivacyViewController(dataPrivcyNotice: DataPrivacyNotice?, error: SCWorkerError?,
                                               delegate: SCCitizenSurveyDetailViewDelegate) {
        guard nil == error,
              let dpn = dataPrivcyNotice else {
            showErrorDialog(error: error)
            return
        }
        display?.present(viewController: injector.getCitizenSurveyDataPrivacyViewController(survey: survey,
                                                                                            delegate: delegate,
                                                                                            dataPrivacyNotice: dpn))
    }
    
    private func showErrorDialog(error: SCWorkerError?) {
        guard let error = error else {
            display?.showErrorDialog(with: LocalizationKeys.SCCitizenSurveyDetailPresenter.dialogTechnicalErrorMessage.localized(),
                                     retryHandler: nil,
                                     showCancelButton: false,
                                     additionalButtonTitle: nil,
                                     additionButtonHandler: nil)
            return
        }
        display?.showErrorDialog(error, retryHandler: nil,
                                 showCancelButton: false,
                                 additionalButtonTitle: nil,
                                 additionButtonHandler: nil)
        
    }
}

