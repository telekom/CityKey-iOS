//
//  SCCitizenSurveyDataPrivacyPresenting.swift
//  OSCA
//
//  Created by Bhaskar N S on 19/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCCitizenSurveyDataPrivacyPresenting {
    func setDataPrivacyAccepted()
    func informDataPrivacyAccepted()
    func getDataPrivacyContent() -> NSMutableAttributedString?
}
