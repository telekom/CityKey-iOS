//
//  SCCitizenSurveyOverviewPresenter.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 09/12/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCCitizenSurveyOverviewPresenting : SCPresenting {
    func set(display: SCCitizenSurveyOverviewDisplaying)
    func getSurveyList() -> [SCModelCitizenSurveyOverview]
    func displaySurveyDetails(survey: SCModelCitizenSurveyOverview)
    func fetchSurveyList()
}

class SCCitizenSurveyOverviewPresenter {

    private var surveyList: [SCModelCitizenSurveyOverview]
    private weak var display: SCCitizenSurveyOverviewDisplaying?
    private let surveyWorker: SCCitizenSurveyWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let injector: SCCitizenSurveyServiceInjecting & SCAdjustTrackingInjection
    private let serviceData: SCBaseComponentItem

    init(surveyList: [SCModelCitizenSurveyOverview],
         cityContentSharedWorker: SCCityContentSharedWorking,
         surveyWorker: SCCitizenSurveyWorking,
         injector: SCCitizenSurveyServiceInjecting & SCAdjustTrackingInjection,
         serviceData: SCBaseComponentItem) {
        self.surveyList = surveyList
        self.cityContentSharedWorker = cityContentSharedWorker
        self.surveyWorker = surveyWorker
        self.injector = injector
        self.serviceData = serviceData
    }

    private func handleEmptySurveyPresentation() {
        if surveyList.count == 0 {
            display?.displayNoSurveyEmptyView()
        }
    }
}

extension SCCitizenSurveyOverviewPresenter: SCCitizenSurveyOverviewPresenting {

    func viewDidLoad() {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.openServiceSurveyList)
        handleEmptySurveyPresentation()
    }

    func set(display: SCCitizenSurveyOverviewDisplaying) {
        self.display = display
    }

    func getSurveyList() -> [SCModelCitizenSurveyOverview] {
        return surveyList
    }

    func displaySurveyDetails(survey: SCModelCitizenSurveyOverview) {
        display?.push(viewController: injector.getCitizenSurveyDetailViewController(survey: survey,
                                                                                    serviceData: serviceData))
    }

    func fetchSurveyList() {
        let cityID = cityContentSharedWorker.getCityID()
        surveyWorker.getSurveyOverview(ciyId: "\(cityID)") {
            [weak self] (surveys, error) in

            DispatchQueue.main.async {
                self?.display?.endRefreshing()
            }

            guard error == nil else {
                self?.display?.showErrorDialog(error!)
                return
            }

            self?.surveyList = surveys
            self?.display?.updateDataSource()
            self?.handleEmptySurveyPresentation()
        }
    }
}
