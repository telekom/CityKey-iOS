//
//  SCCitizenSurveyDataPrivacyPresenter.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 13/01/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCCitizenSurveyDataPrivacyPresenter: SCCitizenSurveyDataPrivacyPresenting {

    private var survey: SCModelCitizenSurveyOverview
    private let dataCache: SCDataCaching
    private let delegate: SCCitizenSurveyDetailViewDelegate?
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let dataPrivacyNotice: DataPrivacyNotice

    init(survey: SCModelCitizenSurveyOverview,
         dataCache: SCDataCaching,
         delegate: SCCitizenSurveyDetailViewDelegate?,
         cityContentSharedWorker: SCCityContentSharedWorking,
         dataPrivacyNotice: DataPrivacyNotice) {
        self.survey = survey
        self.dataCache = dataCache
        self.delegate = delegate
        self.cityContentSharedWorker = cityContentSharedWorker
        self.dataPrivacyNotice = dataPrivacyNotice
    }

    func getDataPrivacyContent() -> NSMutableAttributedString? {
        guard let dpnText = dataPrivacyNotice.content?.first?.dpnText,
              let attributedText = dpnText.htmlAttributedString else {
            return nil
        }
        
        let dataPrivacyAttributedtext = NSMutableAttributedString(attributedString: attributedText)
        dataPrivacyAttributedtext.replaceFont(with: UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17.0, maxSize: 40.0),
                                              color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
        
        return dataPrivacyAttributedtext
    }

    func setDataPrivacyAccepted() {
        dataCache.setDataPrivacyAccepted(for: survey.id, cityID: "\(cityContentSharedWorker.getCityID())")
    }

    func informDataPrivacyAccepted() {
        delegate?.acceptedDataPrivacy()
    }
}
