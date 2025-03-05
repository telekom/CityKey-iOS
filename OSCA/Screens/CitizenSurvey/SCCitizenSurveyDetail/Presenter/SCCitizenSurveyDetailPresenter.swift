/*
Created by Rutvik Kanbargi on 08/12/20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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

