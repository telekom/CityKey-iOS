/*
Created by Rutvik Kanbargi on 27/11/20.
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

import UIKit

protocol SCCitizenSurveyPageViewPresenting {
    func getSurveyQuestionControllerList() -> [SCCitizenSurveyQuestionViewController]
    func setDisplay(display: SCCitizenSurveyViewControllerDisplaying)
    func submitSurvey()
}

protocol SCCitizenSurveyPageViewPresenterDelegate: AnyObject {
    func nextPage(index: Int)
    func previousPage(index: Int)
}

class SCCitizenSurveyPageViewPresenter: SCCitizenSurveyPageViewPresenting {

    private var citizenSurvey: SCModelCitizenSurvey
    private weak var display: SCCitizenSurveyViewControllerDisplaying?
    private let surveyWorker: SCCitizenSurveyWorking
    private let injector: SCAdjustTrackingInjection
    private let cityContentSharedWorker: SCCityContentSharedWorking

    init(citizenSurvey: SCModelCitizenSurvey,
         surveyWorker: SCCitizenSurveyWorking,
         injector: SCAdjustTrackingInjection,
         cityContentSharedWorker: SCCityContentSharedWorking) {
        self.citizenSurvey = citizenSurvey
        self.surveyWorker = surveyWorker
        self.injector = injector
        self.cityContentSharedWorker = cityContentSharedWorker
    }

    func getSurveyQuestionControllerList() -> [SCCitizenSurveyQuestionViewController] {
        var controllerList = [SCCitizenSurveyQuestionViewController]()
        let sortedQuestions = citizenSurvey.questions.sorted { Int($0.questionOrder) < Int($1.questionOrder) }
        for questionIndex in 0..<citizenSurvey.questions.count {
            controllerList.append(getSurveyQuestionController(questionIndex: questionIndex, delegate: self, surveyQuestion: sortedQuestions[questionIndex], surveyTitle: citizenSurvey.surveyName ?? "", lastPage: questionIndex == (citizenSurvey.questions.count-1)))
        }
        return controllerList
    }

    func setDisplay(display: SCCitizenSurveyViewControllerDisplaying) {
        self.display = display
    }

    private func getSurveyQuestionController(questionIndex: Int,
                                             delegate: SCCitizenSurveyPageViewPresenterDelegate,
                                             surveyQuestion: SCModelQuestionSurvey,
                                             surveyTitle: String,
                                             lastPage: Bool) -> SCCitizenSurveyQuestionViewController {
        let questionViewController =  UIStoryboard(name: "CitizenSurvey", bundle: nil).instantiateViewController(withIdentifier: String(describing: SCCitizenSurveyQuestionViewController.self)) as! SCCitizenSurveyQuestionViewController
        questionViewController.delegate = self
        questionViewController.questionIndex = questionIndex
        let presenter = SCCitizenSurveyQuestionPresenter(surveyQuestion: surveyQuestion, surveyTitle: surveyTitle, lastPage: lastPage)
        questionViewController.presenter = presenter
        return questionViewController
    }

    private func displaySurveySubmitAlert(with cancelCompletion: (() -> Void)? = nil, okCompletion: (() -> Void)? = nil) {
        let cityTitle = cityContentSharedWorker.cityInfo(for: cityContentSharedWorker.getCityID())?.name ?? ""

        let alertTitle = String(format: LocalizationKeys.SCCitizenSurveyPageViewPresenter.cs004SurveyŚubmissionDialogTitle.localized().replaceStringFormatter(), cityTitle)
        let alertMessage = String(format: LocalizationKeys.SCCitizenSurveyPageViewPresenter.cs004SurveySubmissionDialogMessage.localized().replaceStringFormatter(), cityTitle)

        let alertController = UIAlertController(title: alertTitle,
                                                message: alertMessage,
                                                preferredStyle: .alert)

        let cancel = UIAlertAction(title: LocalizationKeys.SCCitizenSurveyPageViewPresenter.apnmt003CancelApnmtCancel.localized(), style: .default) { (action) in
            DispatchQueue.main.async {
                cancelCompletion?()
            }
        }

        let okay = UIAlertAction(title: LocalizationKeys.SCCitizenSurveyPageViewPresenter.p001ProfileConfirmEmailChangeBtn.localized(), style: .default) { (action) in
            DispatchQueue.main.async {
                okCompletion?()
            }
        }

        alertController.addAction(cancel)
        alertController.addAction(okay)
        display?.present(viewController: alertController)
    }

    func submitSurvey() {
        displaySurveySubmitAlert(with: nil, okCompletion: {
            [weak self] in
            guard let storngSelf = self,
                  let surveyId = storngSelf.citizenSurvey.surveyId else {
                return
            }
            self?.injector.trackEvent(eventName: AnalyticsKeys.EventName.submitPoll)
            var surveyAnsweredQuestions = [SCModelSurveyQuestionResult]()

            for question in storngSelf.citizenSurvey.questions {
                for topic in question.topics {
                    for option in topic.options {
                        if option.optionSelected == true {
                            let answeredQuestion = SCModelSurveyQuestionResult(questionId: question.questionId, topicId: topic.topicId, optionNo: option.optionNo ?? -1, freeText: option.textAreaInput ?? "")
                            surveyAnsweredQuestions.append(answeredQuestion)
                        }
                    }
                }
            }

            let surveyResult = SCModelSurveyResult(totalQuestions: storngSelf.citizenSurvey.totalQuestions,
                                                   attemptedQuestions: storngSelf.citizenSurvey.totalQuestions,
                                                   responses: surveyAnsweredQuestions)

            let cityId = storngSelf.cityContentSharedWorker.getCityID()
            storngSelf.surveyWorker.submitSurvey(ciyId: "\(cityId)", surveyId: "\(surveyId)", surveyResult: surveyResult) { [weak self] (isSuccess, error) in
                if isSuccess {
                    DispatchQueue.main.async {
                        self?.display?.popToSurveyListViewController()
                    }
                } else {
                    self?.display?.showErrorDialog(error ?? .technicalError, retryHandler: nil, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                }
            }
        })
    }
}

extension SCCitizenSurveyPageViewPresenter: SCCitizenSurveyPageViewPresenterDelegate {

    func nextPage(index: Int) {
        display?.nextPage(index: index)
    }

    func previousPage(index: Int) {
        display?.previousPage(index: index)
    }
}
