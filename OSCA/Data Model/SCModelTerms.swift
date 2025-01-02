//
//  SCModelTerms.swift
//  SmartCity
//
//  Created by Michael on 30.01.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

struct SCModelTermsDataSecurity: Codable {
    let moEngageLink: String
    let adjustLink: String
    let dataUsage: String
    let dataUsage2: String
    let noticeText: String
}

struct SCModelTerms: Codable {
    let dataSecurity: SCModelTermsDataSecurity
    let faq: String
    let legalNotice: String
    let termsAndConditions: String
}
