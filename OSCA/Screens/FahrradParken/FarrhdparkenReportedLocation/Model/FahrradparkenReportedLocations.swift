//
//  FahrradparkenReportedLocations.swift
//  OSCA
//
//  Created by Bhaskar N S on 22/05/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

// MARK: - FahrradparkenLocation
struct FahrradparkenLocation: Codable {
    let serviceRequestID, description: String?
    let lat, long: Double?
    let serviceName, status: String?
    let mediaURL: String?
    let extendedAttributes: ExtendedAttributes?

    enum CodingKeys: String, CodingKey {
        case serviceRequestID = "service_request_id"
        case description, lat, long
        case serviceName = "service_name"
        case status
        case mediaURL = "media_url"
        case extendedAttributes = "extended_attributes"
    }
}

// MARK: - ExtendedAttributes
struct ExtendedAttributes: Codable {
    let markaspot: Markaspot?
}

// MARK: - Markaspot
struct Markaspot: Codable {
    let statusDescriptiveName, statusHex, statusIcon: String?

    enum CodingKeys: String, CodingKey {
        case statusDescriptiveName = "status_descriptive_name"
        case statusHex = "status_hex"
        case statusIcon = "status_icon"
    }
}
