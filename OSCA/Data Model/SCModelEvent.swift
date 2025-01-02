//
//  SCModelEvent.swift
//  SmartCity
//
//  Created by Alexander Lichius on 19.09.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelEvent: Codable, Equatable {
    let description: String
    let endDate: String
    let startDate: String
    let hasEndTime: Bool
    let hasStartTime: Bool
    let imageURL: SCImageURL?
    let thumbnailURL: SCImageURL?
    let latitude: Double
    let longitude: Double
    let locationName: String
    let locationAddress: String
    let subtitle: String
    let title: String
    let imageCredit: String
    let thumbnailCredit: String
    let pdf: [String]?
    let uid: String
    let link: String
    let categoryDescription: String
    let status: String?
}
