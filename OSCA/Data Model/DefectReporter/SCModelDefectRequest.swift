//
//  SCModelDefectRequest.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 14/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelDefectRequest {
    let lastName: String
    let firstName: String
    let serviceCode: String
    let lat: String
    let long: String
    let email: String
    let description: String
    let mediaUrl: String
    let wasteBinId: String
    let subServiceCode: String
    let location: String
    let streetName: String
    let houseNumber: String
    let postalCode: String
    let phoneNumber: String

    func toModel() -> [String : Any] {
        let bodyDict = ["lastName": lastName,
                        "firstName": firstName,
                        "service_code": serviceCode,
                        "lat": lat,
                        "long": long,
                        "email": email,
                        "description": description,
                        "media_url":  mediaUrl,
                        "wasteBinId": wasteBinId,
                        "sub_service_code": subServiceCode,
                        "streetName": streetName,
                        "houseNumber": houseNumber,
                        "postalCode": postalCode,
                        "phoneNumber": phoneNumber,
                        "location": location] as [String : Any]

        return bodyDict
    }
}
